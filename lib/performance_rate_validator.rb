# frozen_string_literal: true

require_relative 'reported_result_extractor'
module CqmValidators
  class PerformanceRateValidator
    include ReportedResultExtractor
    include BaseValidator

    def initialize; end

    # Nothing to see here - Move along
    def validate(file, data = {})
      errors_list = []
      document = get_document(file)
      # grab measure IDs from QRDA file
      measure_ids = document.xpath(measure_selector).map(&:value).map(&:upcase)
      measure_ids.each do |measure_id|
        measures = HealthDataStandards::CQM::Measure.where(id: measure_id)
        measures.each do |measure|
          result_key = measure['population_ids'].dup
          reported_result, _errors = extract_results_by_ids(measure['id'], result_key, document)
          # only check performace rate when there is one
          next if reported_result['PR'].nil?
          error = check_performance_rates(reported_result, result_key, measure['id'], data)
          errors_list << error unless error.nil?
        end
      end
      errors_list
    end

    def calculate_performance_rates(reported_result)
      # Just in case a measure does not report these populations
      denex = 0
      denexcep = 0
      denom = 0
      numer = 0
      denex = reported_result['DENEX'] unless reported_result['DENEX'].nil?
      denexcep = reported_result['DENEXCEP'] unless reported_result['DENEXCEP'].nil?
      denom = reported_result['DENOM'] unless reported_result['DENOM'].nil?
      numer = reported_result['NUMER'] unless reported_result['NUMER'].nil?
      denom = denom - denex - denexcep
      pr = if denom.zero?
             'NA'
           else
             numer / denom.to_f
           end
      pr
    end

    def check_performance_rates(reported_result, population_ids, _measure_id, data = {})
      expected = calculate_performance_rates(reported_result)
      numer_id = population_ids['NUMER']
      if expected == 'NA'
        if reported_result['PR']['nullFlavor'] != 'NA'
          return build_error("Reported Performance Rate for Numerator #{numer_id} should be NA", '/', data[:file_name])
        end
      else
        if reported_result['PR']['nullFlavor'] == 'NA'
          return build_error("Reported Performance Rate for Numerator #{numer_id} should not be NA", '/', data[:file_name])
        elsif reported_result['PR']['value'].split('.', 2).last.size > 6
          return build_error('Reported Performance Rate SHALL not have a precision greater than .000001 ', '/', data[:file_name])
        elsif (reported_result['PR']['value'].to_f - expected.round(6)).abs > 0.0000001
          return build_error("Reported Performance Rate of #{reported_result['PR']['value']} for Numerator #{numer_id} does not match expected value of #{expected.round(6)}.",
                             '/',
                             data[:file_name])
        end
      end
    end

    def measure_selector
      '/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/cda:entry' \
        "/cda:organizer[./cda:templateId[@root='2.16.840.1.113883.10.20.27.3.1']]/cda:reference[@typeCode='REFR']" \
        "/cda:externalDocument[@classCode='DOC']/cda:id[@root='2.16.840.1.113883.4.738']/@extension"
    end
  end
end
