# frozen_string_literal: true
require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'cqm_validators'
require 'nokogiri'
require 'mongoid'

require 'cqm/models'
require 'minitest/autorun'
require 'minitest/reporters'

Mongoid::Config.load!('config/mongoid.yml', :test)
Mongoid::Config.purge!
Mongo::Logger.logger.level = Logger::WARN

module Minitest
  class Test
    extend Minitest::Spec::DSL
    Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

    # Add more helper methods to be used by all tests here...
    def collection_fixtures(collection, *id_attributes)
      Mongoid.client(:default)[collection].drop
      Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', collection, '*.json')).each do |json_fixture_file|
        # puts "Loading #{json_fixture_file}"
        fixture_json = JSON.parse(File.read(json_fixture_file), max_nesting: 250)
        id_attributes.each do |attr|
          fixture_json[attr] = BSON::ObjectId.from_string(fixture_json[attr])
        end

        Mongoid.client(:default)[collection].insert_one(fixture_json)
      end
    end

    # Delete all collections from the database.
    def dump_database
      Mongoid.default_client.drop
    end
  end
end
