
module BusMatchers
  extend RSpec::Matchers::DSL

  matcher :be_a_bus_route do
    match { |actual| actual.is_a?(Hash) and actual['route_id'].is_a?(String) and actual['title'].is_a?(String) }
  end

  matcher :be_populated do
    match { |actual| actual.respond_to?(:empty?) && !actual.empty? }
  end

  alias_matcher :populated, :be_populated
end
