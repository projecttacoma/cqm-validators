# frozen_string_literal: true

module CqmValidators
  module Schematron
    NAMESPACE = { 'svrl' => 'http://purl.oclc.org/dsdl/svrl' }.freeze
    DIR = File.expand_path('..', __dir__)
    ISO_SCHEMATRON = File.join(DIR, 'lib/schematron/iso-schematron-xslt1/iso_svrl_for_xslt1.xsl')

    class Validator
      include BaseValidator
      require_relative 'schematron/processor'
      include Schematron::Processor

      def initialize(name, schematron_file)
        @name = name
        @schematron_file = schematron_file
      end

      def validate(document, data = {})
        file_errors = document.errors.select { |e| e.fatal? || e.error? }
        file_errors&.each do |error|
          build_error(error, '/', data[:file_name])
        end
        errors = get_errors(document).root.xpath('//svrl:failed-assert', NAMESPACE).map do |el|
          build_error(el.xpath('svrl:text', NAMESPACE).text, el['location'], data[:file_name])
        end
        errors.uniq { |e| "#{e.location}#{e.message}" }
      end
    end
  end
end
