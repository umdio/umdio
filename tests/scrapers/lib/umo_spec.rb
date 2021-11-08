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

  describe 'list_route_configs()' do
    subject { routes }

    let(:routes) { UMO.list_route_configs }

    it { is_expected.to be_an Array }
    it { is_expected.not_to be_empty }
    it { is_expected.to all be_a_kind_of Hash }

    context 'each route config' do
      UMO.list_route_configs.each do |route|
        subject { route }

        it_has_behavior 'a valid bus route config'
      end
    end
  end # list_route_configs()

  describe 'get_route_config(route)' do
    subject { route }

    let(:route) { UMO.get_route_config('104') }

    include_examples 'a valid bus route config'

    it { is_expected.to include('tag' => '104') }
    it { is_expected.to include('title' => '104 College Park Metro') }
    it { is_expected.to include('shortTitle' => '104 CP Metro') }
  end

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
