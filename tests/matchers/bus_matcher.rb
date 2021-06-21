module BusMatchers
  extend RSpec::Matchers::DSL

  # A regex that matches "true" or "false" only
  STR_BOOL_REGEX = /^(true|false)$/.freeze
  # A regex that matches both positive and negative integers
  STR_INT_REGEX = /^-?\d+$/.freeze
  # A regex that matches positive integers only
  STR_INT_POS_REGEX = /^\d+$/.freeze

  # matches a valid bus route
  matcher :be_a_bus_route do
    match { |actual| actual.is_a?(Hash) and actual['route_id'].is_a?(String) and actual['title'].is_a?(String) }
  end
  alias_matcher :a_bus_route, :be_a_bus_route

  # matches strings with values that are positive integers
  matcher :be_a_string_encoded_positive_int do
    match { |actual| actual.is_a? String and actual.match STR_INT_POS_REGEX }
  end
  alias_matcher :a_string_encoded_positive_int, :be_a_string_encoded_positive_int

  # matches strings that are exactly "true" or "false"
  matcher :be_a_string_encoded_boolean do
    match { |actual| actual.is_a? String and actual.match STR_BOOL_REGEX }
  end
  alias_matcher :a_string_encoded_boolean, :be_a_string_encoded_boolean
end
