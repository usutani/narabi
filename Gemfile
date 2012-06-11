source 'http://rubygems.org'

gem 'rails', '3.2.5'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

group :development, :test do
  gem 'sqlite3'
end

group :test do
  gem 'cucumber-rails', '~>1.3.0', require: false
  gem 'rspec-rails', '~>2.10.0', require: false
  gem 'database_cleaner', '~>0.7.0', require: false
end

group :production do
  gem 'thin'
  gem 'mysql2', '~>0.3.7'
end


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

#gem 'jquery-rails'
gem 'cloudfoundry-jquery-rails'
gem 'backbone-rails'
gem 'narabi', '0.1.0'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
