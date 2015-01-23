require 'test_helper'

class AddrObjTest < Minitest::Test
  describe Melissa::AddrObj do
    before do
      @uname = `uname`.chomp
      @is_linux = @uname == 'Linux'
      #I like to use test during development:
      #Melissa.config.mode = :mock
    end

    describe "valid?" do
      it 'handles valid data' do
        skip "Not run under #{@uname}" unless @is_linux
        valid_address = Melissa::AddrObj.new(
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
        skip "Not run under #{@uname}" unless @is_linux
        # Zip points to Schenectady, NY
        invalid_address = Melissa::AddrObj.new(
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
        skip "Not run under #{@uname}" unless @is_linux
        valid_address = Melissa::AddrObj.new(
            :address => '2517 SURFWOOD DR',
            :city => 'LAS VEGAS',
            :state => 'NV',
            :zip => '89128'
        )
        assert_equal '89128718217', valid_address.delivery_point
      end

      it 'sets delivery point to nil for invalid data' do
        skip "Not run under #{@uname}" unless @is_linux
        # Zip points to Schenectady, NY
        invalid_address = Melissa::AddrObj.new(
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
        skip "Not run under #{@uname}" unless @is_linux
        valid_address = Melissa::AddrObj.new(
            :address => '2517 SURFWOOD DR',
            :city => 'LAS VEGAS',
            :state => 'NV',
            :zip => '89128'
        )
        assert_operator 30, :>, valid_address.days_until_license_expiration
      end
    end
  end
end
