# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../app/scrapers/courses_scraper'

describe CoursesScraper do
  it_behaves_like 'a scraper'
end
