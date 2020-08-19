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
      document.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      # grab measure IDs from QRDA file
      measure_ids = document.xpath(measure_selector).map(&:value).map(&:upcase)
      measure_ids.each do |measure_id|
        measure = CQM::Measure.where(hqmf_id: measure_id).first
        measure.population_sets.each do |population_set|
          reported_result, = extract_results_by_ids(measure, population_set.population_set_id, document)
          population_set_result = reported_result.population_set_results.first
          # only check performace rate when there is one
          next if population_set_result['PR'].nil?

          error = check_performance_rates(population_set_result, population_set, measure.hqmf_id, data)
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

    def check_performance_rates(reported_result, population_set, _measure_id, data = {})
      expected = calculate_performance_rates(reported_result)
      numer_id = population_set.populations.NUMER.hqmf_id
      if expected == 'NA' && reported_result['PR']['nullFlavor'] != 'NA'
        build_error("Reported Performance Rate for Numerator #{numer_id} should be NA", '/', data[:file_name])
      elsif expected != 'NA' && reported_result['PR']['nullFlavor'] == 'NA'
        build_error("Reported Performance Rate for Numerator #{numer_id} should not be NA", '/', data[:file_name])
      elsif expected != 'NA' && reported_result['PR']['value'].split('.', 2).last.size > 6
        build_error('Reported Performance Rate SHALL not have a precision greater than .000001 ', '/', data[:file_name])
      elsif expected != 'NA' && (reported_result['PR']['value'].to_f - expected.round(6)).abs > 0.0000001
        build_error("Reported Performance Rate of #{reported_result['PR']['value']} for Numerator #{numer_id} does not match expected"\
        " value of #{expected.round(6)}.", '/', data[:file_name])
      end
    end

    def measure_selector
      '/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/cda:entry' \
        "/cda:organizer[./cda:templateId[@root='2.16.840.1.113883.10.20.27.3.1']]/cda:reference[@typeCode='REFR']" \
        "/cda:externalDocument[@classCode='DOC']/cda:id[@root='2.16.840.1.113883.4.738']/@extension"
    end
  end
end
