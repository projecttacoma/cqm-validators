# frozen_string_literal: true

require 'test_helper'
require 'fileutils'

class ReportedResultExtractorTest < Minitest::Test
  include CqmValidators::ReportedResultExtractor

  def setup
    collection_fixtures('cqm_measures')
  end

  def test_should_return_the_correct_reported_result_for_a_cv_value
    doc = File.new('test/fixtures/qrda/cat3_cv_good.xml')
    measure = CQM::Measure.where(hqmf_id: '40280382-5FA6-FE85-015F-BB40A1CD0B95').first
    doc = Nokogiri::XML(doc)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    results = extract_results_by_ids(measure, 'PopulationCriteria1', doc)

    # make sure the OBSERV result (the actual CV value) equals the value from the XML
    assert_equal results['OBSERV'], 15.0
  end

  def test_should_return_the_correct_reported_result_for_a_stratified_cv_value
    doc = File.new('test/fixtures/qrda/cat3_cv_good.xml')
    measure = CQM::Measure.where(hqmf_id: '40280382-5FA6-FE85-015F-BB40A1CD0B95').first
    doc = Nokogiri::XML(doc)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    results = extract_results_by_ids(measure, 'PopulationCriteria1', doc, 'PopulationCriteria1 - Stratification 3')

    # make sure the OBSERV result (the actual CV value) equals the value from the XML
    assert_equal results['OBSERV'], 15.0
  end
end
