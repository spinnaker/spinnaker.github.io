1. Install your favorite ruby version manager (rvm, rbenv, etc)
	1. `rvm install ruby`, or
	1. `rbenv install 2.4.1`
1. `gem install bundle`
1. `bundle install`
1. `bundle exec jekyll serve --watch [--incremental]`

Run link checker before committing: 
`rake test`

(TODO: enforce this via CI build?)
