require 'kramdown'

module Jekyll
  module Filters
    def description(input)
      matches = match_example input
      input = input.gsub matches[0], '' if matches
      input
    end

    def example(input)
      matches = match_example input
      Kramdown::Document.new(matches[1]).to_html if matches
    end

    def match_example(input)
      /<!--\s?EXAMPLE\s?-->([\S\s]*)<!--\s?END(_EXAMPLE)?\s?-->/i.match input
    end

    private :match_example
  end
end

Liquid::Template.register_filter(Jekyll::Filters)
