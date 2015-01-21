=begin
require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class GeoPointTest < ActiveSupport::TestCase

  context AddrObj do
    setup do
      @uname = `uname`.chomp
      @is_linux = @uname == 'Linux'
    end

    should 'handle valid data' do
      skip "Not run under #{@uname}" unless @is_linux
      addr_obj = AddrObj.new(
         :address  => '1960 Glen Lakes Blvd',
         :city     => 'St. Pete',
         :state    => 'FL',
         :zip      => '33702'
      )
      geo_point = GeoPoint.new(addr_obj)
      assert geo_point.valid?
      assert_includes  27.8..27.9, geo_point.latitude
      assert_includes -82.7..-82.6, geo_point.longitude
      offset = Time.now.in_time_zone('US/Eastern').dst? ? 240 : 300
      assert_equal offset, geo_point.time_zone_offset
    end
  end
end
=end

