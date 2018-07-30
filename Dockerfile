# Base image from Ruby docker hub
FROM ruby:2.3.1

# Install essential linux packages
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Define where the application will live inside the image
ENV RAILS_ROOT /var/www/app

# Create application home. App server will need the pids dir
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

# Install bundler
RUN gem install bundler

# Use the Gemfiles as Docker cache markers. Always bundle before copying app src.

COPY Gemfile Gemfile

COPY Gemfile.lock Gemfile.lock

# Finish establishing our Ruby enviornment
RUN bundle install --deployment

# Copy the Rails application into place
COPY . .

RUN RAILS_ENV=production bin/rails assets:precompile

CMD rails server -b 0.0.0.0 --port 3001