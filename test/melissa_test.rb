require 'test_helper'

class MelissaTest < Minitest::Test

  describe 'Melissa.addr_obj' do
    before do
      Melissa.config.mode = :live
    end

    describe "live mode" do
      it 'initializes AddrObjLive object' do
        skip "Not run, Melissa library not loaded" unless Melissa::AddrObjLive.lib_loaded?
        valid_address = Melissa.addr_obj(
            address: '9802 Brompton Dr',
            city: 'Tampa',
            state: 'Fl',
            zip: '33626'
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
            address: '9802 Brompton Dr',
            city: 'Tampa',
            state: 'Fl',
            zip: '33626'
        )
        assert_kind_of Melissa::AddrObjMock, valid_address
      end
    end
  end

  describe 'Melissa.geo_point' do
    before do
      Melissa.config.mode = :live
    end

    describe "live mode" do
      it 'initializes GeoPointLive object' do
        skip "Not run, Melissa library not loaded" unless Melissa::AddrObjLive.lib_loaded?
        skip "Not run, Melissa library not loaded" unless Melissa::GeoPointLive.lib_loaded?
        valid_addr_obj = Melissa.addr_obj(
            address: '9802 Brompton Dr',
            city: 'Tampa',
            state: 'Fl',
            zip: '33626'
        )
        geo_point_obj = Melissa.geo_point(valid_addr_obj)
        assert_kind_of Melissa::GeoPointLive, geo_point_obj
      end
    end

    describe "mock mode" do
      before do
        Melissa.config.mode = :mock
      end

      it 'initializes GeoPointMock object' do
        valid_addr_obj = Melissa.addr_obj(
            address: '9802 Brompton Dr',
            city: 'Tampa',
            state: 'Fl',
            zip: '33626'
        )
        geo_point_obj = Melissa.geo_point(valid_addr_obj)
        assert_kind_of Melissa::GeoPointMock, geo_point_obj
      end
    end
  end
end
