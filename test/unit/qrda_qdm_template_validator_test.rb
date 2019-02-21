# frozen_string_literal: true

require 'test_helper'
class QrdaQdmTemplateValidatorTest < Minitest::Test
  include CqmValidators

  def setup
    @validator_r3 = CqmValidators::QrdaQdmTemplateValidator.new('r3')
    @validator_r31 = CqmValidators::QrdaQdmTemplateValidator.new('r3_1')
    @validator_r6 = CqmValidators::QrdaQdmTemplateValidator.new('r6')
  end

  def test_should_not_produce_errors_if_validator_does_not_support_version_specified
    xml = File.open('./test/fixtures/qrda/cat1_r3_good.xml', 'r', &:read)
    errors = @validator_r6.validate(xml)
    assert_equal 0, errors.length, 'File should not contain any errors'
  end

  def test_should_not_produce_errors_for_good_file
    xml = File.open('./test/fixtures/qrda/cat1_r3_good.xml', 'r', &:read)
    errors = @validator_r3.validate(xml)
    assert_equal 0, errors.length, 'File should not contain any errors'
  end

  def test_should_produce_4_errors_for_using_r3_templates_in_an_r3_1_document
    xml = File.open('./test/fixtures/qrda/cat1_r3_good.xml', 'r', &:read)
    errors = @validator_r31.validate(xml)
    assert_equal 4, errors.length, 'File should contain 4 errors for incorrect templates'
  end
end
