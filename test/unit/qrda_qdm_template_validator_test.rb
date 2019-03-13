# frozen_string_literal: true

require 'test_helper'
class QrdaQdmTemplateValidatorTest < Minitest::Test
  include CqmValidators

  def setup
    @validator_r5 = CqmValidators::QrdaQdmTemplateValidator.new('r5')
    @validator_r51 = CqmValidators::QrdaQdmTemplateValidator.new('r5_1')
    @validator_r6 = CqmValidators::QrdaQdmTemplateValidator.new('r6')
  end

  def test_should_not_produce_errors_if_validator_does_not_support_version_specified
    xml = File.open('./test/fixtures/qrda/cat1_good.xml', 'r', &:read)
    errors = @validator_r6.validate(xml)
    assert_equal 0, errors.length, 'File should not contain any errors'
  end

  def test_should_not_produce_errors_for_good_file
    xml = File.open('./test/fixtures/qrda/cat1_good.xml', 'r', &:read)
    errors = @validator_r51.validate(xml)
    assert_equal 0, errors.length, 'File should not contain any errors'
  end

  def test_should_produce_1_error_for_using_r5_1_templates_in_an_r5_document
    xml = File.open('./test/fixtures/qrda/cat1_good.xml', 'r', &:read)
    errors = @validator_r5.validate(xml)
    assert_equal 1, errors.length, 'File should contain 1 errors for incorrect templates'
  end
end
