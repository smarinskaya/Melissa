require 'test_helper'

class MelissaTest < Minitest::Test
  #TODO comment describe::Config block before live testing
  # describe "Melissa::Config" do
  #   describe "#initialize" do
  #
  #     #TODO this test helped me in development, but the mode depends on the fact,
  #     #TODO that library is not loaded
  #     it "sets default values correctly" do
  #       Melissa::Config.new
  #       assert_equal :mock, Melissa.config.mode
  #     end
  #   end
  #
  #   describe "#config_path=" do
  #     it "correctly loads config settings" do
  #
  #       pwd = File.dirname(__FILE__)
  #       #TODO is there better way to get to the right directory?
  #       top=pwd[0..-6]
  #       melissa_txt = File.join(top,"config/melissa.txt")
  #
  #       config = Melissa.reset
  #       config.config_path = melissa_txt
  #
  #       assert_equal 'valid_license_key', config.license
  #     end
  #   end
  # end

  describe 'Melissa.addr_obj' do
    describe "live mode" do
      it 'initializes AddrObjLive object' do
        skip "Not run in mock mode" unless Melissa.config.mode == :live
        valid_address = Melissa.addr_obj(
            :address => '9802 Brompton Dr',
            :city => 'Tampa',
            :state => 'Fl',
            :zip => '33626'
        )
        assert_kind_of Melissa::AddrObjLive, valid_address
      end
    end

    # describe "mock mode" do
    #   before do
    #     Melissa.config.mode = :mock
    #   end
    #
    #   it 'initializes AddrObjMock object' do
    #     valid_address = Melissa.addr_obj(
    #         :address => '9802 Brompton Dr',
    #         :city => 'Tampa',
    #         :state => 'Fl',
    #         :zip => '33626'
    #     )
    #     assert_kind_of Melissa::AddrObjMock, valid_address
    #   end
    # end
  end

  describe 'Melissa.geo_point' do
    describe "live mode" do
      it 'initializes GeoPointLive object' do
        skip "Not run in mock mode" unless Melissa.config.mode == :live
        valid_addr_obj = Melissa.addr_obj(
            :address => '9802 Brompton Dr',
            :city => 'Tampa',
            :state => 'Fl',
            :zip => '33626'
        )
        geo_point_obj = Melissa.geo_point(valid_addr_obj)
        assert_kind_of Melissa::GeoPointLive, geo_point_obj
      end
    end

    # describe "mock mode" do
    #   before do
    #     Melissa.config.mode = :mock
    #   end
    #
    #   it 'initializes GeoPointMock object' do
    #     valid_addr_obj = Melissa.addr_obj(
    #         :address => '9802 Brompton Dr',
    #         :city => 'Tampa',
    #         :state => 'Fl',
    #         :zip => '33626'
    #     )
    #     geo_point_obj = Melissa.geo_point(valid_addr_obj)
    #     assert_kind_of Melissa::GeoPointMock, geo_point_obj
    #   end
    # end
  end
end