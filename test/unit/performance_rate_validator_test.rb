# frozen_string_literal: true

require 'test_helper'

class PerformanceRateValidatorTest < MiniTest::Test
  include CqmValidators

  def setup
    collection_fixtures('cqm_measures')
    @prcat3 = CqmValidators::Cat3PerformanceRate.instance
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

  def test_should_have_no_errors_if_cat3_performance_rates_are_valid
    doc = File.new('test/fixtures/qrda/cat3_good_performance_rate.xml')
    errors = @prcat3.validate(doc)
    assert_equal [], errors
  end

  def test_should_have_errors_if_performance_rates_are_not_valid
    doc = File.new('test/fixtures/qrda/cat3_bad_performance_rate.xml')
    errors = @prcat3.validate(doc)
    # 1 incorrect performance rates
    assert_equal 1, errors.length
  end

  def test_performance_rate_equals_na_reported_1
    errors_list = []
    reported_result = {}
    reported_result['DENOM'] = 1
    reported_result['DENEX'] = 1
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 0
    reported_result['PR'] = {}
    reported_result['PR']['nullFlavor'] = '1'
    errors = @prcat3.check_performance_rates(reported_result, @proportion_pop_set, nil, file_name: 'test')
    errors_list << errors
    # 1 incorrect performance rate
    assert_equal 1, errors_list.length
  end

  def test_performance_rate_equals_1_reported_1
    reported_result = {}
    reported_result['DENOM'] = 1
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 1
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '1'
    errors = @prcat3.check_performance_rates(reported_result, @proportion_pop_set, nil, file_name: 'test')
    assert_nil errors
  end

  def test_performance_rate_equals_0_reported_0
    reported_result = {}
    reported_result['DENOM'] = 1
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 0
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '0'
    errors = @prcat3.check_performance_rates(reported_result, @proportion_pop_set, nil, file_name: 'test')
    assert_nil errors
  end

  def test_performance_rate_equals_1_reported_1_0
    reported_result = {}
    reported_result['DENOM'] = 1
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 1
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '1.0'
    errors = @prcat3.check_performance_rates(reported_result, @proportion_pop_set, nil, file_name: 'test')
    assert_nil errors
  end

  def test_performance_rate_equals_285714_reported_285714
    reported_result = {}
    reported_result['DENOM'] = 7
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 2
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '0.285714'
    errors = @prcat3.check_performance_rates(reported_result, @proportion_pop_set, nil, file_name: 'test')
    assert_nil errors
  end

  def test_performance_rate_equals_285714_reported_1_285714
    errors_list = []
    reported_result = {}
    reported_result['DENOM'] = 7
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 2
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '1.285714'
    errors = @prcat3.check_performance_rates(reported_result, @proportion_pop_set, nil, file_name: 'test')
    errors_list << errors
    # 1 incorrect performance rate
    assert_equal 1, errors_list.length
  end

  def test_performance_rate_equals_285714_reported_285715
    errors_list = []
    reported_result = {}
    reported_result['DENOM'] = 7
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 2
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '.285715'
    errors = @prcat3.check_performance_rates(reported_result, @proportion_pop_set, nil, file_name: 'test')
    errors_list << errors
    # 1 incorrect performance rate
    assert_equal 1, errors_list.length
  end

  def test_performance_rate_equals_285714_reported_28_5714
    errors_list = []
    reported_result = {}
    reported_result['DENOM'] = 7
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 2
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '28.5714'
    errors = @prcat3.check_performance_rates(reported_result, @proportion_pop_set, nil, file_name: 'test')
    errors_list << errors
    # 1 incorrect performance rate
    assert_equal 1, errors_list.length
  end

  def test_performance_rate_equals_285714_reported_2857142857
    errors_list = []
    reported_result = {}
    reported_result['DENOM'] = 7
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 2
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '.2857142857'
    errors = @prcat3.check_performance_rates(reported_result, @proportion_pop_set, nil, file_name: 'test')
    errors_list << errors
    # 1 incorrect performance rate
    assert_equal 1, errors_list.length
  end

  def test_performance_rate_equals_571429_reported_571428
    errors_list = []
    reported_result = {}
    reported_result['DENOM'] = 7
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 4
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '.571428'
    errors = @prcat3.check_performance_rates(reported_result, @proportion_pop_set, nil, file_name: 'test')
    errors_list << errors
    # 1 incorrect performance rate
    assert_equal 1, errors_list.length
  end
end
