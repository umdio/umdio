# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../app/scrapers/bus_schedules_scraper'

describe BusSchedulesScraper do
  it_behaves_like 'a scraper'
end
