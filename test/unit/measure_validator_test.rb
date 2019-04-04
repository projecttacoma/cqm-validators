# frozen_string_literal: true

require 'test_helper'

class MeasureValidatorTest < ActiveSupport::TestCase
  include CqmValidators

  setup do
    @cat1 = CqmValidators::Cat1Measure.instance
    @cat3 = CqmValidators::Cat3Measure.instance
    collection_fixtures('cqm_measures')
    population = CQM::ProportionPopulationMap.new
    population.build_IPP(hqmf_id: '50BBAAEA-C350-4EFE-8D11-C6D8C39C5DC4')
    population.build_DENOM(hqmf_id: '1920A4B1-D121-4736-814F-0A2D75175063')
    population.build_DENEX(hqmf_id: '1920A4B1-D121-4736-814F-0A2D75175064')
    population.build_DENEXCEP(hqmf_id: '1920A4B1-D121-4736-814F-0A2D75175065')
    population.build_NUMER(hqmf_id: '1D461F91-65B6-43F1-B187-BC056C95DD6D')
    @proportion_pop_set = CQM::PopulationSet.new
    @proportion_pop_set.populations = population
    create_measure
  end

  def create_measure
    measure = CQM::Measure.new(hqmf_id: '40280582-624A-D531-0162-72E0C62000B9',
                               hqmf_set_id: '065C9002-603F-46A3-BA0F-E2A9F1732DC3')
    measure.population_sets << @proportion_pop_set
    measure.save
  end

  test 'should have no errors if measure id is valid (cat 1)' do
    doc = File.new('test/fixtures/qrda/cat1_good.xml')
    errors = @cat1.validate(doc)
    assert_equal [], errors
  end

  test 'should have an error if measure id is invalid (cat 1)' do
    doc = File.new('test/fixtures/qrda/cat1_bad_measure_id.xml')
    errors = @cat1.validate(doc)
    assert_equal 2, errors.length
  end

  test 'should have no errors if measure id is valid (cat 3)' do
    doc = File.new('test/fixtures/qrda/cat3_good.xml')
    errors = @cat3.validate(doc)
    assert_equal [], errors
  end

  test 'should have errors if the measure information is duplicate (cat 3)' do
    doc = File.new('test/fixtures/qrda/cat3_duplicate_measure.xml')
    errors = @cat3.validate(doc)
    assert_equal 3, errors.length # 1 error for each duplicate population
  end

  test 'should have errors if the measure information is duplicate (cat 3), even if measure id is missing' do
    doc = File.new('test/fixtures/qrda/cat3_duplicate_measure_bad_measure_id.xml')
    errors = @cat3.validate(doc)
    assert_equal 3, errors.length # 1 error for each duplicate population
  end

  test 'should have errors if the measure information is duplicate (cat 3), even if pop ids are invalid' do
    doc = File.new('test/fixtures/qrda/cat3_duplicate_measure_bad_pop_id.xml')
    errors = @cat3.validate(doc)
    assert_equal 3, errors.length # 1 error for each duplicate population
  end

  test 'should have an error if measure id is invalid (cat 3)' do
    doc = File.new('test/fixtures/qrda/cat3_bad_measure_id.xml')
    errors = @cat3.validate(doc)
    assert_equal 2, errors.length
  end

  test 'should have an error if set id is invalid (cat 1)' do
    doc = File.new('test/fixtures/qrda/cat1_setId_bad.xml')
    errors = @cat1.validate(doc)
    assert_equal 1, errors.length
  end

  test 'should have an error if set id is valid but for different measure (cat 1)' do
    doc = File.new('test/fixtures/qrda/cat1_setId_wrong.xml')
    errors = @cat1.validate(doc)
    assert_equal 1, errors.length
  end

  test 'should have multiple errors for invalid and wrong set ids (cat 1)' do
    doc = File.new('test/fixtures/qrda/cat1_setId_1good_1bad_1wrong_1missing.xml')
    errors = @cat1.validate(doc)
    assert_equal 2, errors.length
  end
end
