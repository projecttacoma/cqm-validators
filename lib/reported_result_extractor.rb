# frozen_string_literal: true

module CqmValidators
  module ReportedResultExtractor
    # takes a document and a list of 1 or more id hashes, e.g.:
    # [{measure_id:"8a4d92b2-36af-5758-0136-ea8c43244986", set_id:"03876d69-085b-415c-ae9d-9924171040c2", ipp:"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF",
    # den:"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", num:"9363135E-A816-451F-8022-96CDA7E540DD"}]
    # returns nil if nothing matching is found
    # returns a hash with the values of the populations filled out along with the population_ids added to the result

    ALL_POPULATION_CODES = %w[IPP DENOM NUMER NUMEX DENEX DENEXCEP MSRPOPL MSRPOPLEX].freeze

    def extract_results_by_ids(measure, poulation_set_id, doc, stratification_id = nil)
      results = nil
      nodes = find_measure_node(measure.hqmf_id, doc)

      if nodes.nil? || nodes.empty?
        # short circuit and return nil
        return {}
      end

      nodes.each do |n|
        popset_index = measure.population_sets_and_stratifications_for_measure.find_index do |pop_set|
          pop_set[:population_set_id] == poulation_set_id
        end
        results = get_measure_components(n, measure.population_sets.where(population_set_id: poulation_set_id).first, stratification_id, popset_index)
        break if !results.nil? || (!results.nil? && !results.empty?)
      end
      return nil if results.nil?

      results
    end

    def find_measure_node(id, doc)
      xpath_measures = %(/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section
       /cda:entry/cda:organizer[ ./cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.1"]
       and ./cda:reference/cda:externalDocument/cda:id[#{translate('@extension')}='#{id.upcase}' and #{translate('@root')}='2.16.840.1.113883.4.738']])
      doc.xpath(xpath_measures)
    end

    def get_measure_components(n, population_set, stratification_id, popset_index)
      # observations are a hash of population/value. For example {"DENOM"=>108.0, "NUMER"=>2}
      results = { supplemental_data: {}, observations: {} }
      stratification = stratification_id ? population_set.stratifications.where(stratification_id: stratification_id).first.hqmf_id : nil
      ALL_POPULATION_CODES.each do |pop_code|
        next unless population_set.populations[pop_code]

        get_observed_values(results, n, pop_code, population_set, stratification, popset_index)
        val, sup, pr = extract_component_value(n, pop_code, population_set.populations[pop_code]['hqmf_id'], stratification)
        unless val.nil?
          results[pop_code] = val
          results[:supplemental_data][pop_code] = sup
        end
        results['PR'] = pr unless pr.nil?
      end
      results
    end

    def get_observed_values(results, n, pop_code, population_set, stratification, popset_index)
      statement_name = population_set.populations[pop_code]['statement_name']
      # look to see if there is an observation that corresponds to the specific statement_name
      statement_observation = population_set.observations.select { |obs| obs.observation_parameter.statement_name == statement_name }[popset_index]
      # return unless an observation is found
      unless statement_observation.nil?
        hqmf_id = population_set.populations[pop_code]['hqmf_id']
        results[:observations][pop_code] = extract_cv_value(n, statement_observation.hqmf_id, hqmf_id, pop_code, stratification)
      end
    end

    def extract_cv_value(node, id, msrpopl, pop_code, strata = nil)
      xpath_observation = %( cda:component/cda:observation[./cda:value[@code = "#{pop_code}"] and ./cda:reference/cda:externalObservation/cda:id[#{translate('@root')}='#{msrpopl.upcase}']])
      cv = node.at_xpath(xpath_observation)
      return nil unless cv

      val = nil
      if strata
        strata_path = %( cda:entryRelationship[@typeCode="COMP"]/cda:observation[./cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.4"]  and ./cda:reference/cda:externalObservation/cda:id[#{translate('@root')}='#{strata.upcase}']])
        n = cv.xpath(strata_path)
        val = get_cv_value(n, id)
      else
        val = get_cv_value(cv, id)
      end
      val
    end

    def extract_component_value(node, code, id, strata = nil)
      code = 'IPOP' if code == 'IPP'
      xpath_observation = %( cda:component/cda:observation[./cda:value[@code = "#{code}"] and ./cda:reference/cda:externalObservation/cda:id[#{translate('@root')}='#{id.upcase}']])
      cv = node.at_xpath(xpath_observation)
      return nil unless cv

      val = nil
      if strata
        strata_path = %( cda:entryRelationship[@typeCode="COMP"]/cda:observation[./cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.4"]  and ./cda:reference/cda:externalObservation/cda:id[#{translate('@root')}='#{strata.upcase}']])
        n = cv.xpath(strata_path)
        val = get_aggregate_count(n) if n
      else
        val = get_aggregate_count(cv)
      end
      # Performance rate is only applicable for unstratified values
      pref_rate_value = extract_performance_rate(node, code, id) if code == 'NUMER' && strata.nil?
      [val, (strata.nil? ? extract_supplemental_data(cv) : nil), pref_rate_value]
    end

    def extract_performance_rate(node, _code, id)
      xpath_perf_rate = %( cda:component/cda:observation[./cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.14"] and ./cda:reference/cda:externalObservation/cda:id[#{translate('@root')}='#{id.upcase}']]/cda:value)
      perf_rate = node.at_xpath(xpath_perf_rate)
      pref_rate_value = {}
      unless perf_rate.nil?
        if perf_rate.at_xpath('./@nullFlavor')
          pref_rate_value['nullFlavor'] = 'NA'
        else
          pref_rate_value['value'] = perf_rate.at_xpath('./@value').value
        end
        return pref_rate_value
      end
      nil
    end

    # convert numbers in value nodes to Int / Float as necessary
    # TODO: add more types other than 'REAL'
    def convert_value(value_node)
      return if value_node.nil?
      return value_node['value'].to_f if value_node['type'] == 'REAL' || value_node['value'].include?('.')

      value_node['value'].to_i
    end

    # given an observation node with an aggregate count node, return the reported and expected value within the count node
    def get_cv_value(node, cv_id)
      xpath_value = %(cda:entryRelationship/cda:observation[./cda:templateId[@root="2.16.840.1.113883.10.20.27.3.2"] and ./cda:reference/cda:externalObservation/cda:id[#{translate('@root')}='#{cv_id.upcase}']]/cda:value)

      value_node = node.at_xpath(xpath_value)
      value = convert_value(value_node) if value_node
      value
    end

    # given an observation node with an aggregate count node, return the reported and expected value within the count node
    def get_aggregate_count(node)
      xpath_value = 'cda:entryRelationship/cda:observation[./cda:templateId[@root="2.16.840.1.113883.10.20.27.3.3"]]/cda:value'
      value_node = node.at_xpath(xpath_value)
      value = convert_value(value_node) if value_node
      value
    end

    def extract_supplemental_data(cv)
      ret = {}
      supplemental_data_mapping = { 'RACE' => '2.16.840.1.113883.10.20.27.3.8',
                                    'ETHNICITY' => '2.16.840.1.113883.10.20.27.3.7',
                                    'SEX' => '2.16.840.1.113883.10.20.27.3.6',
                                    'PAYER' => '2.16.840.1.113883.10.20.27.3.9' }
      supplemental_data_mapping.each_pair do |supp, id|
        key_hash = {}
        xpath = "cda:entryRelationship/cda:observation[cda:templateId[@root='#{id}']]"
        (cv.xpath(xpath) || []).each do |node|
          value = node.at_xpath('cda:value')
          count = get_aggregate_count(node)
          if value.at_xpath('./@nullFlavor')
            if supp == 'PAYER' && value['xsi:type'] == 'CD' && value['nullFlavor'] == 'OTH' && value.at_xpath('cda:translation') && value.at_xpath('cda:translation')['code']
              key_hash[value.at_xpath('cda:translation')['code']] = count
            else
              key_hash['UNK'] = count
            end
          else
            key_hash[value['code']] = count
          end
        end
        ret[supp.to_s] = key_hash
      end
      ret
    end

    def translate(id)
      %{translate(#{id}, "abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ")}
    end
  end
end
