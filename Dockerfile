## generate and run a rails app with github.com/spree/spree installed
##
## docker build -t b-sh/spree .
## docker run -it -p 3000:3000 b-sh/spree

FROM rlister/ruby:2.1.2

MAINTAINER b-sh

RUN apt-get update && apt-get install -yq \
    git \
    nodejs \
    imagemagick \
    libsqlite3-dev \
    sqlite3

RUN echo "gem: --no-rdoc --no-ri" >> ~/.gemrc
RUN gem install rails -v 4.2.2
RUN gem install spree

RUN rails _4.2.2_ new /app -s
RUN spree install -A /app --branch "3-0-stable"
RUN cd app/ && bundle exec rake railties:install:migrations
RUN cd app/ && bundle exec rake db:migrate
RUN cd app/ && RAILS_ENV=development AUTO_ACCEPT=true bundle exec rake db:seed
##RUN cd app/ && RAILS_ENV=development AUTO_ACCEPT=true bundle exec rake spree_sample:load
RUN echo "" >> /app/Gemfile
RUN echo "gem 'spree_travel_core', :github => 'openjaf/spree_travel_core', :branch => '3-0-stable'" >> /app/Gemfile
RUN cd app/ && bundle install
RUN cd app/ && rails g spree_travel_core:install --migrate=true
RUN cd app/ && bundle exec rake db:migrate
RUN echo "gem 'spree_travel_hotel', :github => 'openjaf/spree_travel_hotel', :branch => '3-0-stable'" >> /app/Gemfile
RUN cd app/ && bundle install
RUN cd app/ && rails g spree_travel_hotel:install --migrate=true
RUN cd app/ && AUTO_ACCEPT=true rake spree_travel_hotel:load
RUN cd app/ && bundle exec rake db:migrate

WORKDIR /app

EXPOSE 3000

ENTRYPOINT [ "bin/bundle", "exec" ]

CMD rails s -b 0.0.0.0
