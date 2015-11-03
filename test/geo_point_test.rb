#require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test_helper'

class GeoPointTest < Minitest::Test
  describe Melissa::GeoPoint do
    describe 'live mode' do
      before do
        Melissa.config.mode = :live
      end

      describe 'valid?' do
        it 'creates valid GeoPoint object from valid Address Object' do
          skip 'Not run, Melissa library not loaded' unless Melissa::GeoPointLive.lib_loaded?
          valid_addr_obj = Melissa.addr_obj(
            address: '2517 SURFWOOD DR',
            city:    'LAS VEGAS',
            state:   'NV',
            zip:     '89128'
          )
          geo_point_obj  = Melissa.geo_point(valid_addr_obj)
          assert geo_point_obj.valid?
          assert_includes 36.2..36.3, geo_point_obj.latitude
          assert_includes -115.3..-115.2, geo_point_obj.longitude
          offset = Time.now.in_time_zone('US/Pacific').dst? ? 420 : 480
          assert_equal offset, geo_point_obj.time_zone_offset(valid_addr_obj.state)
        end
        it 'creates valid GeoPoint object from the Hash' do
          skip 'Not run, Melissa library not loaded' unless Melissa::GeoPointLive.lib_loaded?
          geo_point_obj= Melissa.geo_point(
            zip:                 '89128',
            plus4:               '7182',
            delivery_point_code: '17'
          )

          assert geo_point_obj.valid?
          assert_includes 36.2..36.3, geo_point_obj.latitude
          assert_includes -115.3..-115.2, geo_point_obj.longitude
          offset = Time.now.in_time_zone('US/Pacific').dst? ? 420 : 480
          assert_equal offset, geo_point_obj.time_zone_offset
        end
      end

      describe 'number of days till licence expires' do
        it 'checks if we have more than 30 days till license expiration date' do
          skip 'Not run, Melissa library not loaded' unless Melissa::GeoPointLive.lib_loaded?
          valid_addr_obj = Melissa.addr_obj(
            address: '2517 SURFWOOD DR',
            city:    'LAS VEGAS',
            state:   'NV',
            zip:     '89128'
          )
          geo_point      = Melissa.geo_point(valid_addr_obj)
          assert_operator 30, :<, geo_point.class.days_until_license_expiration
        end
      end

      describe 'callback' do
        it 'executes added callback' do
          skip 'Not run, Melissa library not loaded' unless Melissa::GeoPointLive.lib_loaded?
          callback_flag = false
          Melissa::GeoPoint.add_callback do
            callback_flag = true
          end

          valid_addr_obj = Melissa.addr_obj(
            address: '2517 SURFWOOD DR',
            city:    'LAS VEGAS',
            state:   'NV',
            zip:     '89128'
          )
          Melissa.geo_point(valid_addr_obj)

          assert callback_flag
        end
      end
    end

    describe 'mock mode' do
      before do
        Melissa.config.mode = :mock
      end

      describe 'callback' do
        it 'executes added callback' do
          callback_flag = false
          Melissa::AddrObj.add_callback do
            callback_flag = true
          end

          valid_addr_obj = Melissa.addr_obj(
            address: '2517 Surfwood Dr',
            city:    'Las Vegas',
            state:   'NV',
            zip:     '89128'
          )
          Melissa.geo_point(valid_addr_obj)

          assert callback_flag
        end
      end
    end
  end
end
