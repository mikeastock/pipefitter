FROM ruby:2.2-onbuild
MAINTAINER Mike Stock <mikeastock@gmail.com>

ENV PORT=9292
EXPOSE $PORT

CMD bundle exec rackup --host 0.0.0.0 --port $PORT
