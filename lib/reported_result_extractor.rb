# frozen_string_literal: true

module CqmValidators
  module ReportedResultExtractor
    # takes a document and a list of 1 or more id hashes, e.g.:
    # [{measure_id:"8a4d92b2-36af-5758-0136-ea8c43244986", set_id:"03876d69-085b-415c-ae9d-9924171040c2", ipp:"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF",
    # den:"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", num:"9363135E-A816-451F-8022-96CDA7E540DD"}]
    # returns nil if nothing matching is found
    # returns a hash with the values of the populations filled out along with the population_ids added to the result

    ALL_POPULATION_CODES = %w[IPP DENOM NUMER NUMEX DENEX DENEXCEP MSRPOPL MSRPOPLEX OBSERV].freeze

    def extract_results_by_ids(measure, poulation_set_id, doc, stratification_id = nil)
      aggregate_result = AggregateResult.new(measure_id: measure.id)
      nodes = find_measure_node(measure.hqmf_id, doc)

      if nodes.nil? || nodes.empty?
        # short circuit and return nil
        return nil
      end

      nodes.each do |node|
        get_measure_components(node, measure.population_sets.where(population_set_id: poulation_set_id).first, stratification_id, aggregate_result)
      end
      aggregate_result
    end

    def find_measure_node(id, doc)
      xpath_measures = %(/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section
       /cda:entry/cda:organizer[ ./cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.1"]
       and ./cda:reference/cda:externalDocument/cda:id[#{translate('@extension')}='#{id.upcase}' and #{translate('@root')}='2.16.840.1.113883.4.738']])
      doc.xpath(xpath_measures)
    end

    def get_measure_components(node, population_set, stratification_id, aggregate_result)
      # results = { supplemental_data: {} }
      population_set_result = PopulationSetResult.new(population_set_id: population_set[:population_set_id], stratification_id: stratification_id)

      stratification = stratification_id ? population_set.stratifications.where(stratification_id: stratification_id).first.hqmf_id : nil
      ALL_POPULATION_CODES.each do |pop_code|
        next unless population_set.populations[pop_code] || pop_code == 'OBSERV'

        val = nil
        sup = nil
        if pop_code == 'OBSERV'
          next unless population_set.populations['MSRPOPL']

          msrpopl = population_set.populations['MSRPOPL']['hqmf_id']
          val, sup = extract_continuous_variable_value(node, population_set.observations.first.hqmf_id, msrpopl, stratification)
        else
          val, sup, pr = extract_component_value(node, pop_code, population_set.populations[pop_code]['hqmf_id'], stratification)
        end
        unless val.nil?
          population_set_result[pop_code] = val
          population_set_result.supplemental_information << sup.each { |sup_info| sup_info.population = pop_code } if sup
        end
        population_set_result['PR'] = pr unless pr.nil?
      end
      aggregate_result.population_set_results << population_set_result
    end

    def extract_continuous_variable_value(node, id, msrpopl, strata = nil)
      xpath_observation = %( cda:component/cda:observation[./cda:value[@code = "MSRPOPL"] and ./cda:reference/cda:externalObservation/cda:id[#{translate('@root')}='#{msrpopl.upcase}']])
      component_value = node.at_xpath(xpath_observation)
      return nil unless component_value

      val = nil
      if strata
        strata_path = %( cda:entryRelationship[@typeCode="COMP"]/cda:observation[./cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.4"]  and ./cda:reference/cda:externalObservation/cda:id[#{translate('@root')}='#{strata.upcase}']])
        n = component_value.xpath(strata_path)
        val = get_continuous_variable_value(n, id)
      else
        val = get_continuous_variable_value(component_value, id)
      end
      [val, (strata.nil? ? extract_supplemental_data(component_value) : nil)]
    end

    def extract_component_value(node, code, id, strata = nil)
      code = 'IPOP' if code == 'IPP'
      xpath_observation = %( cda:component/cda:observation[./cda:value[@code = "#{code}"] and ./cda:reference/cda:externalObservation/cda:id[#{translate('@root')}='#{id.upcase}']])
      component_value = node.at_xpath(xpath_observation)
      return nil unless component_value

      val = nil
      if strata
        strata_path = %( cda:entryRelationship[@typeCode="COMP"]/cda:observation[./cda:templateId[@root = "2.16.840.1.113883.10.20.27.3.4"]  and ./cda:reference/cda:externalObservation/cda:id[#{translate('@root')}='#{strata.upcase}']])
        strata_node = component_value.xpath(strata_path)
        val = get_aggregate_count(strata_node) if strata_node
      else
        val = get_aggregate_count(component_value)
      end
      # Performance rate is only applicable for unstratified values
      pref_rate_value = extract_performance_rate(node, code, id) if code == 'NUMER' && strata.nil?
      [val, (strata.nil? ? extract_supplemental_data(component_value) : nil), pref_rate_value]
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
    def get_continuous_variable_value(node, cv_id)
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

    def extract_supplemental_data(component)
      supplemental_information = []
      supplemental_data_mapping = { 'RACE' => '2.16.840.1.113883.10.20.27.3.8',
                                    'ETHNICITY' => '2.16.840.1.113883.10.20.27.3.7',
                                    'SEX' => '2.16.840.1.113883.10.20.27.3.6',
                                    'PAYER' => '2.16.840.1.113883.10.20.27.3.9' }
      supplemental_data_mapping.each_pair do |supp, id|
        key_hash = {}
        xpath = "cda:entryRelationship/cda:observation[cda:templateId[@root='#{id}']]"
        (component.xpath(xpath) || []).each do |node|
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
        create_supplemental_information_from_hash(supp, key_hash, supplemental_information)
      end
      supplemental_information
    end

    def create_supplemental_information_from_hash(supplemental_information_type, key_hash, supplemental_information_list = [])
      key_hash.each do |code, count|
        supplemental_information_list << SupplementalInformation.new(patient_count: count, code: code, key: supplemental_information_type)
      end
    end

    def translate(id)
      %{translate(#{id}, "abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ")}
    end
  end
end
