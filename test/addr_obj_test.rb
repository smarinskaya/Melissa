require 'test_helper'


class AddrObjTest < Minitest::Test
  describe Melissa::AddrObj do
    before do
      #TODO I am not sure about this.
      #TODO in our case, we can use this condition, because
      #TODO Melissa is installed in release and prod, i.e Linux systems.
      #TODO For a public gem, I should not make this type of assumption.
      @uname = `uname`.chomp
      @is_linux = @uname == 'Linux'
      if @is_linux
        Melissa.config.mode = :prod
      else
        Melissa.config.mode = :mock
      end
    end

    describe "valid?" do
      it 'handles valid data' do
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
        valid_address = Melissa::AddrObj.new(
            :address => '2517 SURFWOOD DR',
            :city => 'LAS VEGAS',
            :state => 'NV',
            :zip => '89128'
        )
        assert_equal '89128718217', valid_address.delivery_point
      end

      it 'sets delivery point to nil for invalid data' do
        # Zip points to Schenectady, NY
        invalid_address = Melissa::AddrObj.new(
            :address => '123 Who Dr',
            :city => 'WhoVille',
            :state => 'IN',
            :zip => '12345'
        )

        puts "Invalid address: #{invalid_address.inspect}"

        assert_equal nil, invalid_address.delivery_point
      end
    end
  end
end
