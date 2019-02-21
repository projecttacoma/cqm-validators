# frozen_string_literal: true

require 'test_helper'

class BaseValidatorTest < Minitest::Test
  class TestValidator
    include CqmValidators::BaseValidator
  end

  def setup
    @validator = TestValidator.new
  end

  def test_accept_input_as_string
    doc = File.new('test/fixtures/qrda/cat1_good.xml').read
    assert_equal ::Nokogiri::XML::Document, @validator.get_document(doc).class
  end

  def test_accept_input_as_file
    doc = File.new('test/fixtures/qrda/cat1_bad_measure_id.xml')
    assert_equal ::Nokogiri::XML::Document, @validator.get_document(doc).class
  end

  def test_accept_input_as_nokogiri_document
    doc = Nokogiri::XML(File.new('test/fixtures/qrda/cat3_good.xml').read)
    assert_equal ::Nokogiri::XML::Document, @validator.get_document(doc).class
  end
end
