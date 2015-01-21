require 'csv'
require 'sync_attr'

module Melissa
  class MockValidator
    include SyncAttr

    MockAddressStruct = Struct.new(:street_address_1, :street_address_2, :city, :state, :zip_code, :delivery_point)

    sync_cattr_reader :in_memory do
      addresses = []
      input_file = File.join(File.dirname(__FILE__), "valid_addresses.csv")

      CSV.foreach(input_file, headers: true) do |line|
        #  puts line
        record = MockAddressStruct.new(line["Street Address 1"], line["Street Address 2"], line["City"], line["State"], line["Zip Code"], line["Delivery Point"])

        addresses << record
      end
      addresses
    end

    def self.valid?(address, suite, city, state, zip)
      record = self.retrieve_record(address, suite, city, state, zip)
      return !record.nil?
    end

    def self.get_delivery_point(address, suite, city, state, zip)
      record = self.retrieve_record(address, suite, city, state, zip)
      puts "in get_delivery_point: #{record}, #{record.nil?}"
      if record.nil?
       return nil
      else
        return record.delivery_point
      end
    end

    def self.retrieve_record(address, suite, city, state, zip)
      return self.in_memory.find { |item| item.street_address_1 == address && item.street_address_2 == suite && item.city == city && item.state == state && item.zip_code == zip }
    end
  end
end