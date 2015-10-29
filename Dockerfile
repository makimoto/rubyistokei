FROM ruby:2.2

MAINTAINER Shimpei Makimoto "https://github.com/makimoto"

RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && echo 'Asia/Tokyo' > /etc/timezone

RUN gem update --system
RUN gem install bundler --no-ri --no-rdoc

WORKDIR /app
ADD . /app
RUN bundle install

ENV PORT 19292
EXPOSE 19292

CMD bundle exec thin start -p $PORT -e RACK_ENV
