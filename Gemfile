source 'https://rubygems.org'

gemspec

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in test mode:
group :test do
  gem 'activerecord', '~> 2.3', :require => 'active_record'
  gem 'dm-core', '~> 1.0'
  gem 'dm-aggregates', '~> 1.0'
  gem 'dm-types', '~> 1.0'
  gem 'dm-migrations', '~> 1.0'
  gem 'dm-sqlite-adapter', '~> 1.0'
  gem 'dm-validations', '~> 1.0'
  gem 'rspec', '~> 1.3'
  gem 'sequel', '~> 3.18'
  if 'java' == RUBY_PLATFORM
    gem 'activerecord-jdbcsqlite3-adapter', '~> 1.0', :platform => :jruby
    gem 'jdbc-sqlite3', '~> 3.6', :platform => :jruby
  else
    gem 'sqlite3', '~> 1.3'
  end
  gem 'webrat', '~> 0.7'
end
