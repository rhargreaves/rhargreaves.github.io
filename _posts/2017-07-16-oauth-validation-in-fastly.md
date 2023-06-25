---
layout: post
title: "OAuth 1.0 Signature Validation in Fastly VCL"
date: '2017-07-16 18:00:00 +0000'
tags:
- Fastly
- VCL
- Varnish
- Development
categories:
- Development
description: Making use of Fastly's VCL cryptographic functions to validate OAuth 1.0 signatures on the edge.
---

Sometimes you want to be able to cache protected content in your CDN. One
method of protecting content against unauthorised access is to use OAuth 1.0
authentication. However, since this requires an unique signature to be provided and validated for
each request, it makes it non-trivial to cache such content and protect access at the same time.

[Fastly](http://www.fastly.com) is a CDN based on Varnish.
As such, you are able to add logic in the form of [VCL](https://varnish-cache.org/docs/trunk/users-guide/vcl.html) on the edge. In addition to the standard functionality contained within VCL, Fastly also provide
access to [cryptographic functions](https://docs.fastly.com/guides/vcl/cryptographic-and-hashing-related-vcl-functions)
as well as other handy utilities such as regular expression, time and URL manipulation functions.

Whilst there are [limitations](https://github.com/rhargreaves/fastly-vcl-experiments#limitations) to the breadth of protection that can be provided, it is possible to use these included libraries to perform basic OAuth 1.0 signature validation on the edge, thus enabling you to cache protected content.

[Proof of concept VCL code](https://github.com/rhargreaves/fastly-vcl-experiments/blob/master/oauth_sig_check.vcl),
together with [tests](https://github.com/rhargreaves/fastly-vcl-experiments/blob/master/test/oauth_sig_check_test.py)
can be found my [Fastly VCL Experiments](https://github.com/rhargreaves/fastly-vcl-experiments) repository on GitHub.
