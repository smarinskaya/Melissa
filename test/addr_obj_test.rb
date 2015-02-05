require 'test_helper'

class AddrObjTest < Minitest::Test
  describe Melissa::AddrObj do

    describe "live mode" do
      describe "valid?" do
        it 'handles valid data' do
          skip "Not run in mock mode" unless Melissa.config.mode == :live
          valid_address = Melissa.addr_obj(
              :address => '2517 SURFWOOD DR',
              :city => 'LAS VEGAS',
              :state => 'NV',
              :zip => '89128'
          )
          assert valid_address.valid?
          assert_equal '2517 SURFWOOD DR', valid_address.address
          assert_equal 'LAS VEGAS', valid_address.city
          assert_equal '89128718217', valid_address.delivery_point
        end

        it 'flags invalid data' do
          skip "Not run in mock mode" unless Melissa.config.mode == :live
          # Zip points to Schenectady, NY
          invalid_address = Melissa.addr_obj(
              :address => '123 Who Dr',
              :city => 'WhoVille',
              :state => 'IN',
              :zip => '12345'
          )
          assert !invalid_address.valid?
        end
      end

      describe "delivery_point" do
        it 'sets delivery point for valid data' do
          skip "Not run in mock mode" unless Melissa.config.mode == :live
          valid_address = Melissa.addr_obj(
              :address => '2517 SURFWOOD DR',
              :city => 'LAS VEGAS',
              :state => 'NV',
              :zip => '89128'
          )
          assert_equal '89128718217', valid_address.delivery_point
        end

        it 'sets delivery point to nil for invalid data' do
          skip "Not run in mock mode" unless Melissa.config.mode == :live
          # Zip points to Schenectady, NY
          invalid_address = Melissa.addr_obj(
              :address => '123 Who Dr',
              :city => 'WhoVille',
              :state => 'IN',
              :zip => '12345'
          )
          assert_equal nil, invalid_address.delivery_point
        end
      end

      describe 'number of days till licence expires' do
        it 'checks if we have more than 30 days till license expiration date' do
          skip "Not run in mock mode" unless Melissa.config.mode == :live
          valid_address = Melissa.addr_obj(
              :address => '2517 SURFWOOD DR',
              :city => 'LAS VEGAS',
              :state => 'NV',
              :zip => '89128'
          )
          assert_operator 30, :>, valid_address.days_until_license_expiration
        end
      end
    end

    describe "mock mode" do
      describe "valid?" do
        it 'handles valid data' do
          puts "@@@we are here: #{Melissa.config.mode}"
          valid_address = Melissa.addr_obj(
              :address => '9802 Brompton Dr',
              :city => 'Tampa',
              :state => 'Fl',
              :zip => '33626'
          )
          assert valid_address.valid?
          assert_equal '9802 Brompton Dr', valid_address.address
          assert_equal 'Tampa', valid_address.city
          assert_equal '33626123426', valid_address.delivery_point
        end

        it 'flags invalid data' do
          # Zip points to Schenectady, NY
          invalid_address = Melissa.addr_obj(
              :address => '123 Who Dr',
              :city => 'WhoVille',
              :state => 'IN',
              :zip => ''
          )
          assert !invalid_address.valid?
        end
      end

      describe "delivery_point" do
        it 'sets delivery point for valid data' do
          valid_address = Melissa.addr_obj(
              :address => '9802 Brompton Dr',
              :city => 'Tampa',
              :state => 'Fl',
              :zip => '33626'
          )
          assert_equal '33626123426', valid_address.delivery_point
        end
      end
    end
  end
end
