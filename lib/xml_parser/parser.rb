# frozen_string_literal: true

require 'benchmark'

module XMLParser
  class Parser
    def initialize(file, element)
      @file = file
      @element = element
      raise 'Element definition must be a Hash {element: string, attribute: string, attr_value: string}' unless @element.class.name == 'Hash'
      raise 'File does not exist. Put it in tmp/' unless File.exist?("tmp/#{@file}")
    end

    def self.benchmark_demo
      element ||= { element: 'field', attribute: 'name', attr_value: 'Value' }
      file_small  = '_small-file.xml'
      file_medium = '_medium-file.xml'
      file_large  = '_large-file.xml'
      file_xl     = '_xl-file.xml'
      files = [{ file: file_small, i: 50 },
               { file: file_medium, i: 5 },
               { file: file_large,  i: 1 },
               { file: file_xl, i: 1 }]

      perform_benchmark(files, element)
    end

    def self.benchmark(file:, element:, iterations:)
      @file = file
      @element = element
      raise 'Element definition must be a Hash {element: string, attribute: string, attr_value: string}' unless @element.class.name == 'Hash'
      raise 'File does not exist. Put it in tmp/' unless File.exist?("tmp/#{@file}")

      files = [{ file: file, i: iterations }]

      perform_benchmark(files, element)
    end

    def dom
      DomParser.new(@file, @element)
    end

    def sax
      parser = Nokogiri::XML::SAX::Parser.new(SAXParser.new(@element))
      parser.parse(File.open("tmp/#{@file}"))
      parser.document
    end

    private

    def self.perform_benchmark(files, element)
      Benchmark.bm(30) do |b|
        files.each do |file|
          b.report("SAX: #{file[:i]}x #{file[:file]}") do
            file[:i].times { Parser.new(file[:file], element).sax.data.inject(:+) }
          end
          b.report("DOM: #{file[:i]}x #{file[:file]}") do
            file[:i].times { Parser.new(file[:file], element).dom.data.inject(:+) }
          end
        end
      end
    end
  end
end
