# Base stage for building gems
FROM        ruby:2.6.8-buster as base
ENV         BUNDLER_VERSION 2.0.2
RUN         echo "deb http://deb.debian.org/debian buster main" >> /etc/apt/sources.list \
         && curl -O https://mediaarea.net/repo/deb/repo-mediaarea_1.0-19_all.deb && dpkg -i repo-mediaarea_1.0-19_all.deb \
         && apt-get update && apt-get upgrade -y build-essential \
         && apt-get install -y --no-install-recommends \
            cmake \
            pkg-config \
            zip \
            git \
            nodejs \
            yarn \
            libxslt1-dev \
            libpq-dev \
            build-essential \
            ruby-dev \
            libxml2-dev \
            dumb-init \
         && gem install bundler \
         && rm -rf /var/lib/apt/lists/* \
         && apt-get clean

RUN         mkdir -p /home/app/avalon
WORKDIR     /home/app/avalon

COPY        Gemfile ./Gemfile
COPY        Gemfile.lock ./Gemfile.lock
COPY        package.json ./package.json
RUN         bundle config build.nokogiri --use-system-libraries \
         && bundle install --with aws development test postgres --without production qa
# CMD export HOME=/home/app && rm -f tmp/pids/server.pid && bundle exec rake db:migrate && bin/rails server -b 0.0.0.0

# Download stage takes advantage of parallel build
FROM        ruby:2.6.8-buster as download
RUN         curl https://chromedriver.storage.googleapis.com/2.46/chromedriver_linux64.zip -o /usr/local/bin/chromedriver \
         && chmod +x /usr/local/bin/chromedriver \
         && curl -L https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64-v0.6.1.tar.gz | tar xvz -C /usr/bin/ \
         && mkdir -p /tmp/ffmpeg && cd /tmp/ffmpeg \
         && curl https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz | tar xJ \
         && cp `find . -type f -executable` /usr/bin/


# Dev stage for building dev image
FROM        ruby:2.6.8-buster as dev
ENV         BUNDLER_VERSION 2.0.2
RUN         apt-get update && apt-get install -y --no-install-recommends curl gnupg2 \
         && curl -sL http://deb.nodesource.com/setup_8.x | bash - \
         && curl -O https://mediaarea.net/repo/deb/repo-mediaarea_1.0-19_all.deb && dpkg -i repo-mediaarea_1.0-19_all.deb \
         && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
         && echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN         apt-get update && apt-get install -y --no-install-recommends \
            yarn \
            nodejs \
            lsof \
            x264 \
            sendmail \
            git \
            libxml2-dev \
            libxslt-dev \
            libpq-dev \
            mediainfo \
            openssh-client \
            zip \
            imagemagick \
            dumb-init \
         && gem install bundler \
         && apt-get install -yf \
         && ln -s /usr/bin/lsof /usr/sbin/

ARG         AVALON_BRANCH=develop
ARG         RAILS_ENV=development
ARG         BASE_URL
ARG         DATABASE_URL
ARG         SECRET_KEY_BASE

COPY        --from=base /usr/local/bundle /usr/local/bundle
COPY        --from=download /usr/local/bin/chromedriver /usr/local/bin/chromedriver
COPY        --from=download /usr/bin/ff* /usr/bin/
COPY        --from=download /usr/bin/dockerize /usr/bin/

WORKDIR     /home/app/avalon

RUN         apt-get -y install git nodejs yarn libxslt1-dev libpq-dev build-essential ruby-dev libxml2-dev dumb-init libappindicator1 fonts-liberation
RUN         apt --fix-broken install -y
RUN         curl https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /chrome.deb
RUN         dpkg -i /chrome.deb || apt-get install -yf

# RUN yarn install
# RUN ls && bundle config build.nokogiri --use-system-libraries && bundle install
# RUN cp config/controlled_vocabulary.yml.example config/controlled_vocabulary.yml

CMD export HOME=/home/app && rm -f tmp/pids/server.pid && bundle exec rake db:migrate && yarn install && bin/rails server -b 0.0.0.0
