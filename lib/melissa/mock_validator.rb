require 'csv'

module Melissa
  class MockValidator
    #include SyncAttr

    MockAddressStruct = Struct.new(:street_address_1, :street_address_2, :city, :state, :zip_code, :delivery_point)

    #use memoization
    def self.in_memory
      @@in_memory ||= begin
        addresses = []
        input_file = File.join(File.dirname(__FILE__), "valid_addresses.csv")

        CSV.foreach(input_file, headers: true) do |line|
          #  puts line
          record = MockAddressStruct.new(line["Street Address 1"], line["Street Address 2"], line["City"], line["State"], line["Zip Code"], line["Delivery Point"])
          addresses << record
        end
        addresses
      end
    end

    def self.valid?(address, suite, city, state, zip)
      record = self.retrieve_record(address, suite, city, state, zip)
      return !record.nil?
    end

    def self.get_delivery_point(address, suite, city, state, zip)
      record = self.retrieve_record(address, suite, city, state, zip)
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