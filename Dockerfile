FROM ruby:3.1.0

WORKDIR /elasticsearch_exam
COPY Gemfile /elasticsearch_exam/Gemfile
COPY Gemfile.lock /elasticsearch_exam/Gemfile.lock
RUN bundle config --local set path 'vendor/bundle' && bundle install