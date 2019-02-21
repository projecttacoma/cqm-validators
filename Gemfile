# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in cqm_validators.gemspec
gemspec development_group: :test

gem 'health-data-standards', github: 'projectcypress/health-data-standards', branch: 'master_bonnie'

group :test do
  gem 'codecov', require: false
  gem 'simplecov', require: false
end
