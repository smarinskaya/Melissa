#require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test_helper'

class GeoPointTest < Minitest::Test

  describe Melissa::GeoPoint do
    before do
      @uname = `uname`.chomp
      @is_linux = @uname == 'Linux'
    end

    describe 'valid?' do
      it 'handles valid data' do
        skip "Not run under #{@uname}" unless @is_linux
        addr_obj = Melissa::AddrObj.new(
            :address => '2517 SURFWOOD DR',
            :city => 'LAS VEGAS',
            :state => 'NV',
            :zip => '89128'
        )
        geo_point = Melissa::GeoPoint.new(addr_obj)
        assert geo_point.valid?
        assert_includes  36.2..36.3, geo_point.latitude
        assert_includes -115.3..-115.2, geo_point.longitude
        # offset = Time.now.in_time_zone('US/Eastern').dst? ? 240 : 300
        # assert_equal offset, geo_point.time_zone_offset
        #For the address above:
        #g.time_zone_offset
        #=> 480

      end
    end
  end
end


