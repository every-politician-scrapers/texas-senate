#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'open-uri/cached'
require 'pry'

class MemberList
  # details for an individual member
  class Member < Scraped::HTML
    field :name do
      image_node.parent.xpath('following-sibling::a').text.tidy
    end

    field :constituency do
      noko.css('.shrinkb').text.tidy
    end

    private

    def image_node
      noko.css('img').first
    end
  end

  # The page listing all the members
  class Members < Scraped::HTML
    field :members do
      member_container.map { |member| fragment(member => Member).to_h }
    end

    private

    def member_container
      noko.css('.memlist .mempicdiv')
    end
  end
end

url = 'https://senate.texas.gov/members.php'
puts EveryPoliticianScraper::ScraperData.new(url).csv
