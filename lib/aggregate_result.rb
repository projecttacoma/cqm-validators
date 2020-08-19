# frozen_string_literal: true

class AggregateResult
  include Mongoid::Document

  embeds_many :population_set_results
  field :measure_id

  def add_individual_result(individual_result)
    return unless measure_id == individual_result.measure_id

    psk = individual_result.population_set_key
    measure = Measure.find(measure_id)
    psh = population_set_hash_for_key(psk, measure)
    psr = population_set_results.find_or_create_by(population_set_id: psh[:population_set_id], stratification_id: psh[:stratification_id])
    psr.add_individual_result(individual_result, measure)
  end

  private

  # This method returns an population_set_hash (from the population_sets_and_stratifications_for_measure)
  # for a given 'population_set_key.' The popluation_set_key is the key used by the cqm-execution-service
  # to reference the population set for a specific set of calculation results
  def population_set_hash_for_key(population_set_key, measure)
    population_set_hash = population_sets_and_stratifications_for_measure(measure)
    population_set_hash.keep_if { |ps| [ps[:population_set_id], ps[:stratification_id]].include? population_set_key }.first
  end

  # A measure may have 1 or more population sets that may have 1 or more stratifications
  # This method returns an array of hashes with the population_set and stratification_id for every combindation
  def population_sets_and_stratifications_for_measure(measure)
    population_set_array = []
    measure.population_sets.each do |population_set|
      population_set_hash = { population_set_id: population_set.population_set_id }
      next if population_set_array.include? population_set_hash

      population_set_array << population_set_hash
      population_set.stratifications.each do |stratification|
        population_set_stratification_hash = { population_set_id: population_set.population_set_id,
                                               stratification_id: stratification.stratification_id }
        population_set_array << population_set_stratification_hash
      end
    end
    population_set_array
  end
end

class PopulationSetResult
  include Mongoid::Document

  embedded_in :aggregate_result
  field :population_set_id, type: String
  field :stratification_id, type: String

  # Population Attributes
  field :STRAT, type: Integer, default: 0
  field :IPP, type: Integer, default: 0
  field :DENOM, type: Integer, default: 0
  field :NUMER, type: Integer, default: 0
  field :NUMEX, type: Integer, default: 0
  field :DENEX, type: Integer, default: 0
  field :DENEXCEP, type: Integer, default: 0
  field :MSRPOPL, type: Integer, default: 0
  field :OBSERV, type: Float, default: 0
  field :MSRPOPLEX, type: Integer, default: 0
  field :PR

  field :observation_values, type: Array, default: []

  delegate :measure_id, to: :aggregate_result

  embeds_many :supplemental_information

  def population_set_hash
    { population_set_id: population_set_id, stratification_id: stratification_id }
  end

  def population_set_key
    stratification_id || population_set_id
  end

  def get_supplemental_information(populations = [], codes = [])
    supplemental_information.select { |si| populations.include?(si.population) && codes.include?(si.code) }
  end

  def add_individual_result(individual_result, measure)
    measure.population_keys.each do |pop|
      next if individual_result[pop].nil? || individual_result[pop].zero?

      self[pop] += individual_result[pop]
      # For each population, increment supplemental information counts
      next if stratification_id

      increment_sup_info(individual_result.patient.qdmPatient, pop)
    end
    # extract the observed value from an individual results.  Observed values are in the 'episode result'.
    # Each episode will have its own observation
    self[:observation_values].concat get_observ_values(individual_result['episode_results']) if individual_result['episode_results']
    self[:OBSERV] = self[:observation_values] ? median(self[:observation_values].reject(&:nil?)) : 0.0
  end

  def get_observ_values(episode_results)
    episode_results.collect_concat do |_id, episode_result|
      # Only use observed values when a patient is in the MSRPOPL and not in the MSRPOPLEX
      next unless episode_result['MSRPOPL']&.positive? && !episode_result['MSRPOPLEX']&.positive?

      episode_result['observation_values']
    end
  end

  def increment_sup_info(qdm_patient, population)
    sex = qdm_patient.get_data_elements('patient_characteristic', 'gender')[0].dataElementCodes[0].code
    increment_sup_code('SEX', population, sex)

    race = qdm_patient.get_data_elements('patient_characteristic', 'race')[0].dataElementCodes[0].code
    increment_sup_code('RACE', population, race)

    ethnicity = qdm_patient.get_data_elements('patient_characteristic', 'ethnicity')[0].dataElementCodes[0].code
    increment_sup_code('ETHNICITY', population, ethnicity)

    payer = qdm_patient.get_data_elements('patient_characteristic', 'payer')[0].dataElementCodes[0].code
    increment_sup_code('PAYER', population, payer.to_s)
  end

  private

  def increment_sup_code(type, population, code)
    si = supplemental_information.find_or_create_by(key: type, population: population, code: code)
    si.increment
  end

  def median(array, already_sorted = false)
    return 0.0 if array.empty?

    array = array.sort unless already_sorted
    m_pos = array.size / 2
    array.size.odd? ? array[m_pos] : mean(array[m_pos - 1..m_pos])
  end

  def mean(array)
    return 0.0 if array.empty?

    array.inject(0.0) { |sum, elem| sum + elem } / array.size
  end
end

class SupplementalInformation
  include Mongoid::Document

  validates :population, inclusion: %w[IPP DENOM NUMER NUMEX DENEX DENEXCEP MSRPOPL MSRPOPLEX]

  field :population, type: String
  field :patient_count, type: Integer, default: 0
  field :code, type: String
  field :key, type: String
  embedded_in :population_set_result

  def increment
    self.patient_count += 1
  end
end
