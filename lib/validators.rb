# frozen_string_literal: true

require_relative 'validation_error'
require_relative 'base_validator'
require_relative 'schema_validator'
require_relative 'schematron_validator'
require_relative 'measure_validator'
require_relative 'data_validator'
require_relative 'performance_rate_validator'
require_relative 'qrda_qdm_template_validator'

module CqmValidators
  CDA_SDTC_SCHEMA = 'lib/schema/infrastructure/cda/CDA_SDTC.xsd'
  QRDA_CAT1_R5_SCHEMATRON = 'lib/schematron/qrda/cat_1_r5/HL7 QRDA Category I STU 5.sch'
  QRDA_CAT1_R51_SCHEMATRON = 'lib/schematron/qrda/cat_1_r5_1/HL7 QRDA Category I STU 5.1.sch'
  QRDA_CAT3_21SCHEMATRON = 'lib/schematron/qrda/cat_3_r2_1/HL7 QRDA Category III STU 2.1.sch'
  BASE_DIR = File.expand_path('..', __dir__)

  class Cat1Measure < MeasureValidator
    include Singleton

    def initialize
      super('2.16.840.1.113883.10.20.24.3.97')
    end
  end

  class Cat3Measure < MeasureValidator
    include Singleton

    def initialize
      super('2.16.840.1.113883.10.20.27.3.1')
    end
  end

  class CDA < Schema::Validator
    include Singleton

    def initialize
      super('CDA SDTC Validator', File.join(BASE_DIR, CDA_SDTC_SCHEMA))
    end
  end

  class Cat1R5 < Schematron::Validator
    include Singleton

    def initialize
      super('QRDA Cat 1 Validator', File.join(BASE_DIR, QRDA_CAT1_R5_SCHEMATRON))
    end
  end

  class Cat1R51 < Schematron::Validator
    include Singleton

    def initialize
      super('QRDA Cat 1 Validator', File.join(BASE_DIR, QRDA_CAT1_R51_SCHEMATRON))
    end
  end

  class Cat3R21 < Schematron::Validator
    include Singleton

    def initialize
      super('QRDA Cat 3 Validator', File.join(BASE_DIR, QRDA_CAT3_21SCHEMATRON))
    end
  end

  class Cat3PerformanceRate < PerformanceRateValidator
    include Singleton
  end
end
