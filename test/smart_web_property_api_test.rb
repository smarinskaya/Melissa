require 'test_helper'
require 'pry'

class PropertyAPITest < MiniTest::Test
  describe Melissa::WebSmart::Client do
    it 'gets a response' do
      res = Melissa::WebSmart::Client.new.property("12071", "24-43-24-03-00022.0040")
      assert res[:result].keys.sort == [:code, :description]
    end
  end
end
