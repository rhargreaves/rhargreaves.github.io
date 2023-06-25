FROM ruby:2.3-alpine
RUN apk add ruby-dev build-base
RUN gem install bundler
WORKDIR /app
COPY Gemfile* ./
RUN bundle install
CMD bundle exec jekyll serve
