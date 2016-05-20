source 'https://rubygems.org'

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

gem 'rake',                   :require => false
gem 'puppetlabs_spec_helper', :require => false
gem 'puppet-lint',            :require => false
gem 'puppet-syntax',          :require => false
gem 'rspec-puppet',           :require => false
gem 'coveralls',              :require => false
gem 'simplecov',              :require => false
gem 'metadata-json-lint',     :require => false

# gem 'puppetlabs_spec_helper', :git => 'https://github.com/puppetlabs/puppetlabs_spec_helper', :require => true
# gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet', :require => true

gem 'rspec', '~> 3.1.0',    :platforms => :ruby_18
