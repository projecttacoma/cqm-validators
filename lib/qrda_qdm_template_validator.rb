# frozen_string_literal: true

module CqmValidators
  class QrdaQdmTemplateValidator
    include BaseValidator

    # Hash of templateIds/extensions specified in the Patient Data Section QDM for QRDA R5
    QRDA_CAT_1_R5_QDM_OIDS = {
      '2.16.840.1.113883.10.20.24.3.1' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.2' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.3' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.4' => '2017-08-01',
      # '2.16.840.1.113883.10.20.24.3.5' => '2016-02-01', Removed
      # '2.16.840.1.113883.10.20.24.3.6' => '2016-02-01', Removed
      '2.16.840.1.113883.10.20.24.3.7' => '2017-08-01',
      # '2.16.840.1.113883.10.20.24.3.8' => '2016-02-01',
      '2.16.840.1.113883.10.20.24.3.130' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.131' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.137' => '2017-08-01',
      # '2.16.840.1.113883.10.20.24.3.15' => '2016-02-01', Removed
      # '2.16.840.1.113883.10.20.24.3.16' => '2016-02-01', Removed
      '2.16.840.1.113883.10.20.24.3.17' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.18' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.19' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.105' => '2016-02-01',
      # '2.16.840.1.113883.10.20.24.3.21' => '2016-02-01', Removed
      '2.16.840.1.113883.10.20.24.3.132' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.133' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.134' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.12' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.140' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.143' => '2017-08-01',
      # '2.16.840.1.113883.10.20.24.3.29' => '2016-02-01', Removed
      # '2.16.840.1.113883.10.20.24.3.30' => '2016-02-01', Removed
      '2.16.840.1.113883.10.20.24.3.31' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.32' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.33' => '2017-08-01',
      # '2.16.840.1.113883.10.20.24.3.35' => '2016-02-01', Removed
      # '2.16.840.1.113883.10.20.24.3.36' => '2016-02-01', Removed
      '2.16.840.1.113883.10.20.24.3.37' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.38' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.39' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.41' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.42' => '2017-08-01',
      # '2.16.840.1.113883.10.20.24.3.43' => '2016-02-01', Removed
      # '2.16.840.1.113883.10.20.24.3.44' => '2016-02-01', Removed
      '2.16.840.1.113883.10.20.24.3.139' => '2017-08-01',
      # '2.16.840.1.113883.10.20.24.3.46' => '2016-02-01', Removed
      '2.16.840.1.113883.10.20.24.3.47' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.48' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.51' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.54' => '2016-02-01',
      '2.16.840.1.113883.10.20.24.3.103' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.58' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.59' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.55' => nil,
      '2.16.840.1.113883.10.20.24.3.60' => '2017-08-01',
      # '2.16.840.1.113883.10.20.24.3.61' => '2016-02-01', Removed
      # '2.16.840.1.113883.10.20.24.3.62' => '2016-02-01', Removed
      '2.16.840.1.113883.10.20.24.3.63' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.64' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.65' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.67' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.75' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.138' => '2017-08-01',
      # '2.16.840.1.113883.10.20.24.3.141' => nil, Removed
      # '2.16.840.1.113883.10.20.24.3.142' => nil, Removed
      '2.16.840.1.113883.10.20.24.3.144' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.145' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.146' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.147' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.114' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.154' => '2017-08-01'
    }.freeze
    # Hash of templateIds/extensions specified in the Patient Data Section QDM for QRDA R5.1
    QRDA_CAT_1_R5_1_QDM_OIDS = {
      '2.16.840.1.113883.10.20.24.3.1' => '2017-08-01',
      # '2.16.840.1.113883.10.20.24.3.2' => '2017-08-01', Removed
      # '2.16.840.1.113883.10.20.24.3.3' => '2017-08-01', Removed
      # '2.16.840.1.113883.10.20.24.3.4' => '2017-08-01', Removed
      '2.16.840.1.113883.10.20.24.3.7' => '2018-10-01',
      '2.16.840.1.113883.10.20.24.3.130' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.131' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.137' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.17' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.18' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.19' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.105' => '2018-10-01',
      '2.16.840.1.113883.10.20.24.3.132' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.133' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.134' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.12' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.140' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.143' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.31' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.32' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.33' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.37' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.38' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.39' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.41' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.42' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.139' => '2018-10-01',
      '2.16.840.1.113883.10.20.24.3.47' => '2018-10-01',
      '2.16.840.1.113883.10.20.24.3.48' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.51' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.54' => '2016-02-01',
      '2.16.840.1.113883.10.20.24.3.103' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.58' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.59' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.55' => nil,
      '2.16.840.1.113883.10.20.24.3.60' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.63' => '2018-10-01',
      '2.16.840.1.113883.10.20.24.3.64' => '2018-10-01',
      '2.16.840.1.113883.10.20.24.3.65' => '2018-10-01',
      '2.16.840.1.113883.10.20.24.3.67' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.75' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.138' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.144' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.145' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.146' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.147' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.114' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.154' => '2017-08-01',
      '2.16.840.1.113883.10.20.24.3.156' => '2018-10-01',
      '2.16.840.1.113883.10.20.24.3.158' => '2018-10-01'
    }.freeze

    def initialize(qrda_version)
      @name = 'QRDA QDM Template Validator'
      @templateshash = case qrda_version
                       when 'r5' then QRDA_CAT_1_R5_QDM_OIDS
                       when 'r5_1' then QRDA_CAT_1_R5_1_QDM_OIDS
                       end
    end

    # Validates that a QRDA Cat I file's Patient Data Section QDM (V3) contains entries that conform
    # to the QDM approach to QRDA. In contrast to a QRDA Framework Patient Data Section that requires
    # but does not specify the structured entries, the Patient Data Section QDM contained entry templates
    # have specific requirements to align the quality measure data element type with its corresponding NQF
    # QDM HQMF pattern, its referenced value set and potential QDM attributes.
    # The result will be an Array of execution errors indicating use of templates that are not valid for the
    # specified QRDA version
    def validate(file, data = {})
      @errors = []
      # if validator does not support the qrda version specified, no checks are made
      unless @templateshash.nil?
        @doc = get_document(file)
        @doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
        extract_entries.each do |entry|
          # each entry is evaluated separetly.
          entry_value_for_qrda_version(entry, data)
        end
      end
      @errors
    end

    def entry_value_for_qrda_version(entry, data = {})
      # an entry may have multiple templateIds
      tids = entry.xpath('./*/cda:templateId')
      # an entry only needs one valid templateId to be acceptable
      unless tids.map { |tid| @templateshash.key?(tid['root']) && @templateshash[tid['root']] == tid['extension'] }.include? true
        msg = "#{tids.map { |tid| "#{tid['root']}:#{tid['extension']}" }} are not valid Patient Data Section QDM entries for this QRDA Version"
        @errors << build_error(msg, entry.path, data[:file_name])
      end
    end

    # returns a list of the patient data entries
    def extract_entries
      @doc.xpath('//cda:component/cda:section[cda:templateId/@root="2.16.840.1.113883.10.20.24.2.1"]/cda:entry')
    end
  end
end
