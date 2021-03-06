# frozen_string_literal: true

require 'test_helper'

class XmlFileValidatorTest < ActiveSupport::TestCase
  include CqmValidators

  test 'should be able to tell when a cat III file is bad due to schematron issues' do
    doc = File.new('test/fixtures/qrda/cat3_bad_schematron.xml')
    errors = Cat3R21.instance.validate(doc, file_name: 'filename.xml')
    assert_equal 1, errors.length, 'Should be 1 errors for bad cat 3 file'
  end

  test 'should be able to tell when a cat I file is good' do
    doc = File.new('test/fixtures/qrda/cat1_good.xml')
    errors = Cat1R5.instance.validate(doc, file_name: 'filename.xml')
    assert errors.empty?, 'Should be 0 errors for good cat 1 file'
  end

  test 'should be able to tell when a file is bad due to schema issues' do
    doc = File.new('test/fixtures/qrda/cat1_bad_schema.xml')
    errors = CDA.instance.validate(doc, file_name: 'filename.xml')
    assert_equal 1, errors.length, 'Should report 1 error'
  end

  test 'should be able to tell when a cat I file is bad due to schematron issues' do
    doc = File.new('test/fixtures/qrda/cat1_bad_schematron.xml')
    errors = Cat1R5.instance.validate(doc, file_name: 'filename.xml')
    assert_equal 1, errors.length, 'Should report 1 error'
  end

  test 'should be able to tell when a cat I R5.2 file is bad due to schematron issues' do
    doc = File.new('test/fixtures/qrda/cat1_bad_5_2_schematron.xml')
    errors = Cat1R52.instance.validate(doc, file_name: 'filename.xml')
    assert_equal 1, errors.length, 'Should report 1 error'
  end

  test 'should be able to tell when a cat I file is bad due to not including expected measures' do
    doc = File.new('test/fixtures/qrda/cat1_no_measure_id.xml')
    errors = Cat1R5.instance.validate(doc, file_name: 'filename.xml')
    assert_equal 2, errors.length, 'Should report 2 errors'
  end
end
