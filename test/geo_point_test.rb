#require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test_helper'

class GeoPointTest < Minitest::Test

  describe Melissa::GeoPoint do
    describe 'valid?' do
      it 'handles valid data' do
        skip "Not run in mock mode" unless Melissa.config.mode == :live
        addr_obj = Melissa::AddrObj.new(
            :address => '2517 SURFWOOD DR',
            :city => 'LAS VEGAS',
            :state => 'NV',
            :zip => '89128'
        )
        geo_point = Melissa::GeoPoint.new(addr_obj)
        assert geo_point.valid?
        assert_includes 36.2..36.3, geo_point.latitude
        assert_includes -115.3..-115.2, geo_point.longitude
        # offset = Time.now.in_time_zone('US/Eastern').dst? ? 240 : 300
        # assert_equal offset, geo_point.time_zone_offset
        #For the address above:
        #g.time_zone_offset
        #=> 480
      end
    end

    describe 'number of days till licence expires' do
      it 'checks if we have more than 30 days till license expiration date' do
        skip "Not run in mock mode" unless Melissa.config.mode == :live
        valid_address = Melissa::AddrObj.new(
            :address => '2517 SURFWOOD DR',
            :city => 'LAS VEGAS',
            :state => 'NV',
            :zip => '89128'
        )
        geo_point = Melissa::GeoPoint.new(addr_obj)
        assert_operator 30, :>, geo_point.days_until_license_expiration
      end
    end
  end
end


