require 'test_helper'

class AddrObjTest < Minitest::Test
  describe Melissa::AddrObj do
    describe 'live mode' do
      before do
        Melissa.config.mode = :live
      end

      describe 'valid?' do
        it 'handles valid data' do
          skip 'Not run, Melissa library not loaded' unless Melissa::AddrObjLive.lib_loaded
          valid_address = Melissa.addr_obj(
              address: '2517 Surfwood Dr',
              city: 'Las Vegas',
              state: 'NV',
              zip: '89128'
          )
          assert valid_address.valid?
          assert_equal '2517 Surfwood Dr', valid_address.address
          assert_equal 'Las Vegas', valid_address.city
          assert_equal '89128718217', valid_address.delivery_point
          offset = Time.now.in_time_zone('US/Pacific').dst? ? 420 : 480
          assert_equal offset, valid_address.time_zone_offset
        end

        it 'flags invalid data' do
          skip 'Not run, Melissa library not loaded' unless Melissa::AddrObjLive.lib_loaded
          # Zip points to Schenectady, NY
          invalid_address = Melissa.addr_obj(
              address: '123 Who Dr',
              city: 'WhoVille',
              state: 'IN',
              zip: '12345'
          )
          assert !invalid_address.valid?
        end
      end

      describe 'delivery_point' do
        it 'sets delivery point for valid data' do
          skip 'Not run, Melissa library not loaded' unless Melissa::AddrObjLive.lib_loaded
          valid_address = Melissa.addr_obj(
              address: '2517 Surfwood Dr',
              city: 'Las Vegas',
              state: 'NV',
              zip: '89128'
          )
          assert_equal '89128718217', valid_address.delivery_point
        end
      end

      describe 'address_key' do
        it 'sets address key for valid data' do
          skip 'Not run, Melissa library not loaded' unless Melissa::AddrObjLive.lib_loaded
          valid_address = Melissa.addr_obj(
            address: '9802 Brompton Dr',
            city: 'Tampa',
            state: 'FL',
            zip: '33626'
          )
          assert_equal '33626512502', valid_address.address_key
        end
      end

      describe 'number of days till licence expires' do
        it 'checks if we have more than 30 days till license expiration date' do
          skip 'Not run, Melissa library not loaded' unless Melissa::AddrObjLive.lib_loaded
          valid_address = Melissa.addr_obj(
              :address => '2517 Surfwood Dr',
              :city => 'Las Vegas',
              :state => 'NV',
              :zip => '89128'
          )
          assert_operator 30, :<, valid_address.class.days_until_license_expiration
        end
      end

      describe 'callback' do
        it 'executes added callback' do
          skip 'Not run, Melissa library not loaded' unless Melissa::AddrObjLive.lib_loaded
          callback_flag = false
          Melissa::AddrObj.add_callback do
            callback_flag = true
          end

          valid_address = Melissa.addr_obj(
            address: '2517 Surfwood Dr',
            city: 'Las Vegas',
            state: 'NV',
            zip: '89128'
          )

          assert callback_flag
        end
      end
    end

    describe 'mock mode' do
      before do
        Melissa.config.mode = :mock
      end
      describe 'valid?' do
        it 'handles valid data' do
          valid_address = Melissa.addr_obj(
              address: '9802 Brompton Dr',
              city: 'Tampa',
              state: 'Fl',
              zip: '33626'
          )
          assert valid_address.valid?
          assert_equal '9802 Brompton Dr', valid_address.address
          assert_equal 'Tampa', valid_address.city
          assert_equal '33626123426', valid_address.delivery_point
        end

        it 'flags invalid data' do
          # Zip points to Schenectady, NY
          invalid_address = Melissa.addr_obj(
              address: '123 Who Dr',
              city: 'WhoVille',
              state: 'IN',
              zip: ''
          )
          assert !invalid_address.valid?
        end
      end

      describe 'delivery_point' do
        it 'sets delivery point for valid data' do
          valid_address = Melissa.addr_obj(
              address: '9802 Brompton Dr',
              city: 'Tampa',
              state: 'Fl',
              zip: '33626'
          )
          assert_equal '33626123426', valid_address.delivery_point
        end
      end

      describe 'address_key' do
        it 'sets address key for valid data' do
          valid_address = Melissa.addr_obj(
            address: '9802 Brompton Dr',
            city: 'Tampa',
            state: 'Fl',
            zip: '33626'
          )
          assert_equal '33626123426', valid_address.address_key
        end
      end

      describe 'callback' do
        it 'executes added callback' do
          callback_flag = false
          Melissa::AddrObj.add_callback do
            callback_flag = true
          end

          valid_address = Melissa.addr_obj(
            address: '2517 Surfwood Dr',
            city: 'Las Vegas',
            state: 'NV',
            zip: '89128'
          )

          assert callback_flag
        end
      end
    end
  end
end
