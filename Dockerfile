# Dockerfile to run Jekyll locally and test the generated site
# You must mount $(pwd) to /code (this allows pages to be dynamically regenerated without having to rebuild the Dockerfile)
FROM ruby:2.4.1
RUN apt-get install -y git bzip2 libssl-dev libreadline-dev zlib1g-dev
RUN gem install bundler

# bundle install from a different directory to the /code mount for a large performance increase (at least on Docker-for-Mac)
COPY Gemfile* /install/
COPY *.gemspec /install/
WORKDIR /install
RUN bundle install --frozen

EXPOSE 4000
WORKDIR /code
ENTRYPOINT [ "bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--watch" ]