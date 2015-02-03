require 'test_helper'

class MelissaTest < Minitest::Test
  describe 'Melissa.get_addr_obj' do
    describe "live mode" do
      it 'initializes AddrObjLive object' do
        skip "Not run in mock mode" unless Melissa.config.mode == :live
        valid_address = Melissa.addr_obj(
            :address => '10125 Parley Dr',
            :city => 'Tampa',
            :state => 'Fl',
            :zip => '33626'
        )
        assert_kind_of Melissa::AddrObjLive, valid_address
      end
    end

    describe "mock mode" do
      before do
        Melissa.config.mode = :mock
      end

      it 'initializes AddrObjMock object' do
        valid_address = Melissa.addr_obj(
            :address => '10125 Parley Dr',
            :city => 'Tampa',
            :state => 'Fl',
            :zip => '33626'
        )
        assert_kind_of Melissa::AddrObjMock, valid_address
      end
    end
  end
end