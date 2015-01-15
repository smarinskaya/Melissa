require 'csv'

module Melissa
  class MockValidator
    #TODO beter way is to read csv into class variable
    #TODO and implement class methods.

    #TODO add state
    MockAddressStruct = Struct.new(:street_address_1, :street_address_2, :city, :state, :zip_code, :delivery_point)

    attr_accessor :addresses

    #Will do initialize, and instance methods to start with.
    def initialize
      @addresses = []
      input_file = File.join(File.dirname(__FILE__), "valid_addresses.csv")

      CSV.foreach(input_file, headers: true) do |line|
        #  puts line
        record = MockAddressStruct.new(line["Street Address 1"], line["Street Address 2"], line["City"], line["State"], line["Zip Code"], line["Delivery Point"])

        @addresses << record
      end
    end

    def valid?(address, suite, city, state, zip)
      record = retrieve_record(address, suite, city, state, zip)
      return !record.nil?
    end

    def get_delivery_point(address, suite, city, state, zip)
      record = retrieve_record(address, suite, city, state, zip)
      return record.delivery_point
    end

    def retrieve_record(address, suite, city, state, zip)
      record = @addresses.find { |item| item.street_address_1 == address && item.street_address_2 == suite && item.city == city && item.state == state && item.zip_code == zip }
    end
  end
end