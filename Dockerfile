FROM ruby:2.5.7-alpine

RUN apk update && \
    apk --no-cache add make build-base

WORKDIR /app

RUN gem install bundler jekyll

# Take advantage of incremental builds
COPY jwmarcus-blog/Gemfile .
RUN bundle install

COPY jwmarcus-blog .

EXPOSE 4000
CMD [ "bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0"]
