# frozen_string_literal: true

module XMLParser
  class SAXParser < Nokogiri::XML::SAX::Document
    attr_reader :data

    def initialize(element)
      @element = element
      @data = []
      super()
    end

    def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])
      @element_name = name
      attributes = attrs.first
      if attributes.nil? || attributes == ''
        @attributes = nil
      else
        @attributes = OpenStruct.new(attributes)
      end
    end

    def characters(string)
      value = string.strip
      current_field_hash = {}
      current_field_hash = {element: @element_name, attribute: @attributes&.localname, attr_value: @attributes&.value}
      if match(@element, current_field_hash)
        unless value == ''
          @data << value.to_f unless value == ''
        end
      end
    end

    private
    def match(element, current_field_hash)
      element.keys.all? do |key|
        current_field_hash.include?(key)
        current_field_hash[key] == element[key]
      end
    end
  end
end
