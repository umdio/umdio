# frozen_string_literal: true

require_relative '../../spec_helper'
require_relative '../../../app/scrapers/lib/umo'

describe UMO do
  describe 'get_routes()' do
    let(:routes) { UMO.get_routes }

    it 'returns a list of routes' do
      expect(routes).to be_an Array
      expect(routes).not_to be_empty
    end # get_routes()

    it 'each route has a tag, title, and shortTitle' do
      expect(routes).to all include(
        'tag' => (a_kind_of(String).and match(/^[0-9]+$/)),
        'title' => (a_kind_of String),
        'shortTitle' => (a_kind_of(String).or be_nil)
      )
    end
  end

  describe 'get_route_config()' do
    subject { routes }

    let(:routes) { UMO.get_route_config }

    it { is_expected.to be_an Array }
    it { is_expected.not_to be_empty }

    context 'each returned route config' do
      it 'includes a tag' do
        expect(subject).to all include('tag' => (a_kind_of(String).and match(/^[0-9a-z]+$/)))
      end

      it 'includes a min/max value for lat/lon specifying the route extent' do
        expect(routes).to all include(
          'latMin' => a_kind_of(Float),
          'latMax' => a_kind_of(Float),
          'lonMin' => a_kind_of(Float),
          'lonMax' => a_kind_of(Float)
        )
      end

      it 'includes a title and an optional shortTitle' do
        expect(routes).to all include(
          'title' => (a_kind_of String),
          'shortTitle' => (a_kind_of(String).or be_nil)
        )
      end

      it 'includes a color and oppositeColor' do
        expect(routes).to all include(
          'color' => (a_kind_of(String).and match(/^[0-9a-f]{6}$/)),
          'oppositeColor' => (a_kind_of(String).and match(/^[0-9a-f]{6}$/))
        )
      end

      it 'includes a list of stops' do
        expect(routes).to all include(
          'stop' => (a_kind_of(Array).and all include(
            'tag' => a_kind_of(String),
            'title' => a_kind_of(String),
            'shortTitle' => (a_kind_of(String).or be_nil),
            'lat' => a_kind_of(Float),
            'lon' => a_kind_of(Float),
            'stopId' => a_kind_of(Integer)
          ))
        )
      end

      it 'includes a list of directions' do
        expect(routes).to all include(
          'direction' => (a_kind_of(Array)).and(
            all(include(
                  'tag' => a_kind_of(String),
                  'title' => a_kind_of(String),
                  'name' => a_kind_of(String),
                  'stop' => (a_kind_of(Array).and all include(
                    'tag' => a_kind_of(String)
                  ))
                ))
          )
        )
      end

      it 'includes a list of paths' do
        routes.each do |route|
          path = route['path']
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
  end # get_route_config()

  describe 'get_schedule()' do
    subject { routes }

    let(:routes) { UMO.get_schedule '104' }

    it 'returns an Array' do
      expect(routes).to be_an Array
      expect(routes).not_to be_empty
    end

    it 'fails when route is nil' do
      expect { described_class.get_schedule }.to raise_error(ArgumentError)
    end

    context 'each returned schedule' do
      it 'includes a tag, title, and direction' do
        expect(routes).to all include(
          'tag' => '104',
          'title' => (a_kind_of String),
          'direction' => a_kind_of(String)
        )
      end

      it 'includes a scheduleClass and serviceClass' do
        expect(routes).to all include(
          'scheduleClass' => a_kind_of(String),
          'serviceClass' => a_kind_of(String)
        )
      end

      it 'includes a header hash' do
        expect(routes).to all include(
          'header' => (a_kind_of Hash).and(
            include(
              'stop' => (a_kind_of(Array).and all include(
                'tag' => a_kind_of(String),
                'content' => a_kind_of(String)
              ))
            )
          )
        )
      end

      it 'contains a list of blocks' do
        expect(routes).to all include(
          'tr' => (a_kind_of(Array).and all include(
            'blockID' => a_kind_of(Integer),
            'stop' => (a_kind_of(Array).and all include(
              'tag' => a_kind_of(String),
              'epochTime' => a_kind_of(Integer),
              # hh:mm:ss in 24-hour format
              'content' => (a_kind_of(String).and match(/^\d{2}:\d{2}:\d{2}$/))
            ))
          ))
        )
      end
    end
  end
end
