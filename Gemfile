ruby '2.0.0'

source 'http://rubygems.org'

gem 'rails', '3.0.10'

# From https://github.com/datasift/datasift-ruby
gem 'datasift', :path => 'vendor/gems/datasift'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development, :test do
  gem 'sqlite3' # Not supported by Heroku; not used anyway.
end
group :production do

gem 'pg' # PostgreSQL
end

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

gem 'rake', '>= 10.1.0'
gem 'rspec'
gem 'resque'
gem 'resque-loner'
gem 'redis'
