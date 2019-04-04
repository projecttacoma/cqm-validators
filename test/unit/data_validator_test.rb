# frozen_string_literal: true

require 'test_helper'

class DataValidatorTest < ActiveSupport::TestCase
  include CqmValidators

  setup do
    collection_fixtures('cqm_measures')
    @vs = CQM::ValueSet.new(oid: '1.2.3.4')
    @vs.concepts << CQM::Concept.new(code: '1234', code_system_oid: '2.16.840.1.113883.6.96', code_system_name: 'SNOMED-CT')
    @vs.save
    measures = CQM::Measure.where(hqmf_id: '40280382-5FA6-FE85-015F-BB40A1CD0B95')
    add_valueset_to_measure(measures)
    @validator = DataValidator.new(measures.map(&:_id))
  end

  def add_valueset_to_measure(measures)
    measures.each do |measure|
      measure.value_sets << @vs
      measure.save
    end
  end

  test 'Should produce errors for unknown valuesets or values not found in vs' do
    xml = File.open('./test/fixtures/qrda/cat1_bad_value_set.xml', 'r', &:read)
    errors = @validator.validate(xml)
    assert_equal 1, errors.length, 'File should contain 1 error'
  end

  test 'Should not produce errors for files for all ' do
    xml = File.open('./test/fixtures/qrda/cat1_good_value_set.xml', 'r', &:read)
    errors = @validator.validate(xml)
    assert_equal 0, errors.length, 'File should not contain any errors'
  end
end
