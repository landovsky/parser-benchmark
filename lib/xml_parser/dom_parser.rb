# frozen_string_literal: true

module XMLParser
  class DomParser
    attr_reader :data

    def initialize(file, element)
      @file = file
      @element = element
      @query = search_query
      @data = []
      dom_parser
    end

    def search_query
      element_name = @element[:element]
      attribute = @element[:attribute]
      attr_value = @element[:attr_value]
      if attribute || attr_value
        raise "Both 'attribute' and 'attribute value' must be defined." unless attribute && attr_value
      end
      attribute_query = "[#{attribute}='#{attr_value}']" if attribute
      element_name.to_s + attribute_query.to_s
    end

    def dom_parser
      @doc = Nokogiri::XML(File.open("tmp/#{@file}"))
      @records = @doc.css(@query)
      @records.each do |item|
        value = item.text.strip.to_f
        @data << value unless value == 0
      end
    end
  end
end
