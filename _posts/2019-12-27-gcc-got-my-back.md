---
layout: post
title: "GCC's got my back"
date: "2019-12-27 09:00:00 +0000"
tags:
  - Retro Computing
  - C
  - GCC
  - Motorola 68000
categories:
  - Development
description: You don't have to be a great C programmer to produce optimal code. That's good!
---

<img src="{{ site.assets }}/gcc/gnu.png" width="250px">

Consider this code:

{% raw %}

```c
typedef struct Foo Foo;

struct Foo {
  int a;
} foo;

Foo foos[100] = {{ 0 }};

void index_incrementing(void) {
  for(int i = 0; i<100; i++) {
    Foo* f = &foos[i];
    f->a++;
  }
  return;
}
```

{% endraw %}

I've been using similar code to loop through an array of structs in C. I considered it good enough, but then
I had a shower moment. I realised that it could be simplified to use pointer arithmetic to accomplish the same
thing, but without the need for a separate `i` index. So:

```c
void pointer_incrementing(void) {
  for(Foo* f = &foos[0]; f < &foos[100]; f++) {
     f->a++;
  }
  return;
}
```

Isn't that cleaner? Well, it's more C'y-er maybe. One less line too! Clearer intent too perhaps.

But was my original approach producing slower code?

Let's look at the assembly!

```asm
foos:
	.zero	400
index_incrementing:
	link.w %fp,#-8
	clr.l -4(%fp)
	jra .L6
.L7:
	move.l -4(%fp),%d0
	lsl.l #2,%d0
	move.l %d0,%d1
	add.l #foos,%d1
	move.l %d1,-8(%fp)
	move.l -8(%fp),%d0
	move.l %d0,%a0
	move.l (%a0),%d0
	move.l %d0,%d1
	addq.l #1,%d1
	move.l -8(%fp),%d0
	move.l %d0,%a0
	move.l %d1,(%a0)
	addq.l #1,-4(%fp)
.L6:
	moveq #99,%d0
	cmp.l -4(%fp),%d0
	jge .L7
	nop
	unlk %fp
	rts
```

This is the assembly when compiled using `gcc` and `-m68000` (yes, Motorola 68000 code, that's [a thing](https://github.com/rhargreaves/mega-drive-midi-interface) I'm doing at the moment). You can see that the L7 loop is 16 instructions long (including the `cmp`). OK, so what about the pointer arithmetic method?

```asm
pointer_incrementing:
	link.w %fp,#-4
	move.l #foos,-4(%fp)
	jra .L2
.L3:
	move.l -4(%fp),%d0
	move.l %d0,%a0
	move.l (%a0),%d0
	move.l %d0,%d1
	addq.l #1,%d1
	move.l -4(%fp),%d0
	move.l %d0,%a0
	move.l %d1,(%a0)
	addq.l #4,-4(%fp)
.L2:
	cmp.l #foos+400,-4(%fp)
	jcs .L3
	nop
	unlk %fp
	rts
```

It's just **10** instructions long! Assuming the instructions take roughly the same amount of time to execute, you could say that's about a third quicker. Oh wow! That's much quicker! I should change my code right away...

## Not so fast

Actually, I shouldn't. At least, I shouldn't change it with the intention that it would speed things up. It turns out that when GCC is instructed to do a basic level of compiler optimisation (i.e. with `-O2`) it will optimise away any differences:

```asm
pointer_incrementing:
	link.w %fp,#0
	lea foos,%a0
.L2:
	addq.l #1,(%a0)
	addq.l #4,%a0
	cmp.l #foos+400,%a0
	jne .L2
	unlk %fp
	rts
index_incrementing:
	link.w %fp,#0
	lea foos,%a0
.L7:
	addq.l #1,(%a0)
	addq.l #4,%a0
	cmp.l #foos+400,%a0
	jne .L7
	unlk %fp
	rts
foos:
	.zero	400
```

So there you have it. I can make the decision to change the code based on which has a clearer intent, rather than decide purely based on which is more optimal. Whichever approach I choose, GCC in this case will optimise away all the fluff.

### Key lessons

Of course before doing any performance optimisations you should always profile your code to ensure that you actually optimising the application as a whole, rather than micro-optimising. Obviously this was a simple example, but it's always worth stating the obvious sometimes. The main advantage of using a higher-level language instead of assembly is that you can concentrate on writing clear, maintainable code that expresses intent, rather than always focusing on how the CPU will execute it.

Fortunately I have been profiling my code, and this was not the bottleneck, but I always find it so insightful to read the code that compilers produce. You forget how amazingly clever these things are. I find that by understanding them better and occasionally verifying what they produce teaches you a lot in what you can expect the compiler to optimise, and what you should help it out with. Checking the assembly output has blown away a lot of my assumptions about "construct X being quicker than construct Y" because the compiler often knows a lot more about how your code is being used the code than your eyes do. Yes, it sometimes gets it wrong, but you should never assume that you know better in all cases. Learning to work with the compiler, rather than in-place of it, is key.
