# frozen_string_literal: true

require 'test_helper'

class PerformanceRateValidatorTest < MiniTest::Test
  include CqmValidators

  def setup
    @prcat3 = CqmValidators::Cat3PerformanceRate.instance
    collection_fixtures('measures')
  end

  def test_should_have_no_errors_if_cat3_performance_rates_are_valid
    doc = File.new('test/fixtures/qrda/cat3_good_performance_rate.xml')
    errors = @prcat3.validate(doc)
    assert_equal [], errors
  end

  def test_should_have_errors_if_performance_rates_are_not_valid
    doc = File.new('test/fixtures/qrda/cat3_bad_performance_rate.xml')
    errors = @prcat3.validate(doc)
    # 2 incorrect performance rates
    assert_equal 2, errors.length
  end

  def test_performance_rate_equals_na_reported_1
    errors_list = []
    population_ids = {}
    population_ids['NUMER'] = 'test_numer'
    reported_result = {}
    reported_result['DENOM'] = 1
    reported_result['DENEX'] = 1
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 0
    reported_result['PR'] = {}
    reported_result['PR']['nullFlavor'] = '1'
    errors = @prcat3.check_performance_rates(reported_result, population_ids, nil, file_name: 'test')
    errors_list << errors
    # 1 incorrect performance rate
    assert_equal 1, errors_list.length
  end

  def test_performance_rate_equals_1_reported_1
    population_ids = {}
    population_ids['NUMER'] = 'test_numer'
    reported_result = {}
    reported_result['DENOM'] = 1
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 1
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '1'
    errors = @prcat3.check_performance_rates(reported_result, population_ids, nil, file_name: 'test')
    assert_nil errors
  end

  def test_performance_rate_equals_0_reported_0
    population_ids = {}
    population_ids['NUMER'] = 'test_numer'
    reported_result = {}
    reported_result['DENOM'] = 1
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 0
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '0'
    errors = @prcat3.check_performance_rates(reported_result, population_ids, nil, file_name: 'test')
    assert_nil errors
  end

  def test_performance_rate_equals_1_reported_1_0
    population_ids = {}
    population_ids['NUMER'] = 'test_numer'
    reported_result = {}
    reported_result['DENOM'] = 1
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 1
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '1.0'
    errors = @prcat3.check_performance_rates(reported_result, population_ids, nil, file_name: 'test')
    assert_nil errors
  end

  def test_performance_rate_equals_285714_reported_285714
    population_ids = {}
    population_ids['NUMER'] = 'test_numer'
    reported_result = {}
    reported_result['DENOM'] = 7
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 2
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '0.285714'
    errors = @prcat3.check_performance_rates(reported_result, population_ids, nil, file_name: 'test')
    assert_nil errors
  end

  def test_performance_rate_equals_285714_reported_1_285714
    errors_list = []
    population_ids = {}
    population_ids['NUMER'] = 'test_numer'
    reported_result = {}
    reported_result['DENOM'] = 7
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 2
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '1.285714'
    errors = @prcat3.check_performance_rates(reported_result, population_ids, nil, file_name: 'test')
    errors_list << errors
    # 1 incorrect performance rate
    assert_equal 1, errors_list.length
  end

  def test_performance_rate_equals_285714_reported_285715
    errors_list = []
    population_ids = {}
    population_ids['NUMER'] = 'test_numer'
    reported_result = {}
    reported_result['DENOM'] = 7
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 2
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '.285715'
    errors = @prcat3.check_performance_rates(reported_result, population_ids, nil, file_name: 'test')
    errors_list << errors
    # 1 incorrect performance rate
    assert_equal 1, errors_list.length
  end

  def test_performance_rate_equals_285714_reported_28_5714
    errors_list = []
    population_ids = {}
    population_ids['NUMER'] = 'test_numer'
    reported_result = {}
    reported_result['DENOM'] = 7
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 2
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '28.5714'
    errors = @prcat3.check_performance_rates(reported_result, population_ids, nil, file_name: 'test')
    errors_list << errors
    # 1 incorrect performance rate
    assert_equal 1, errors_list.length
  end

  def test_performance_rate_equals_285714_reported_2857142857
    errors_list = []
    population_ids = {}
    population_ids['NUMER'] = 'test_numer'
    reported_result = {}
    reported_result['DENOM'] = 7
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 2
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '.2857142857'
    errors = @prcat3.check_performance_rates(reported_result, population_ids, nil, file_name: 'test')
    errors_list << errors
    # 1 incorrect performance rate
    assert_equal 1, errors_list.length
  end

  def test_performance_rate_equals_571429_reported_571428
    errors_list = []
    population_ids = {}
    population_ids['NUMER'] = 'test_numer'
    reported_result = {}
    reported_result['DENOM'] = 7
    reported_result['DENEX'] = 0
    reported_result['DENEXCEP'] = 0
    reported_result['NUMER'] = 4
    reported_result['PR'] = {}
    reported_result['PR']['value'] = '.571428'
    errors = @prcat3.check_performance_rates(reported_result, population_ids, nil, file_name: 'test')
    errors_list << errors
    # 1 incorrect performance rate
    assert_equal 1, errors_list.length
  end
end
