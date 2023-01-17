require 'httparty'
require 'json'
require 'pry'
require_relative './holiday.rb'

class HolidayService
  def self.find_holidays
    HTTParty.get("https://date.nager.at/api/v3/NextPublicHolidays/US")
  end

  def self.parse_holidays
    JSON.parse(find_holidays.body, symbolize_names: true)
  end

  def self.create_holidays
    parse_holidays[0..2].map do |data|
      Holiday.new(data)
    end
  end
end
