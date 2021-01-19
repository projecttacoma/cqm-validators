# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in cqm_validators.gemspec
gemspec development_group: :test

group :test do
  gem 'codecov', require: false
  gem 'cqm-models', git: 'https://github.com/projecttacoma/cqm-models.git', branch: 'master'
  gem 'simplecov', '0.19.0'
end
