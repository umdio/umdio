module BusMatchers
  extend RSpec::Matchers::DSL

  matcher :be_a_bus_route do
    match { |actual| actual.is_a?(Hash) and actual['route_id'].is_a?(String) and actual['title'].is_a?(String) }
  end

  matcher :be_populated do
    match { |actual| actual.respond_to?(:empty?) && !actual.empty? }
  end

  alias_matcher :populated, :be_populated
  shared_examples_for 'a valid bus route config' do
    # subject { config }

    it { is_expected.to be_a Hash }

    it { is_expected.to include('tag' => (a_kind_of(String).and match(/^[0-9a-z]+$/))) }
    it { is_expected.to include('title' => a_kind_of(String)) }
    it { is_expected.to include('shortTitle' => a_kind_of(String).or(be_nil)) }

    it { is_expected.to include('latMin' => a_kind_of(Float)) }
    it { is_expected.to include('latMax' => a_kind_of(Float)) }
    it { is_expected.to include('lonMin' => a_kind_of(Float)) }
    it { is_expected.to include('lonMax' => a_kind_of(Float)) }

    it 'includes a color and oppositeColor' do
      expect(subject).to include(
        'color' => (a_kind_of(String).and match(/^[0-9a-f]{6}$/)),
        'oppositeColor' => (a_kind_of(String).and match(/^[0-9a-f]{6}$/))
      )
    end

    # it { is_expected.to include('stop' => a_kind_of(Array).and(all be_a Hash))}

    it 'includes a list of stops' do
      expect(subject['stop']).to be_a(Array).and all be_a Hash
      expect(subject['stop']).to all include(
        'tag' => a_kind_of(String),
        'title' => a_kind_of(String),
        'shortTitle' => (a_kind_of(String).or be_nil),
        'lat' => a_kind_of(Float),
        'lon' => a_kind_of(Float),
        'stopId' => a_kind_of(Integer)
      )
    end

    it 'includes a list of directions' do
      expect(subject['direction']).to be_a(Array).and all be_a Hash
      expect(subject['direction']).to all include(
        'tag' => a_kind_of(String),
        'title' => a_kind_of(String),
        'name' => a_kind_of(String),
        'stop' => (a_kind_of(Array).and all include(
          'tag' => a_kind_of(String)
        ))
      )
    end

    it 'includes a list of paths' do
      path = subject['path']
      expect(path).to be_an Array
      expect(path).not_to be_empty
      expect(path).to all include(
        'point' => (a_kind_of(Array).and all include(
          'lat' => a_kind_of(Float),
          'lon' => a_kind_of(Float)
        )
                   )
      )
    end
  end
end
