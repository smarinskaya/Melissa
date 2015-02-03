module Melissa
  class GeoPointMock < GeoPoint
    # Since we're faking it, create accessors that just return the corresponding opts value except the ones we dummy in the ctor
    @@melissa_attributes.each do |name|
      name = name.underscore
      class_eval <<-EOS
        define_method(:#{name}) do
          @#{name} ||= (@opts[:#{name}] || '')
        end
      EOS
    end

    def initialize(addr_obj)
      @is_valid = false

      if addr_obj.kind_of?(AddrObj)
        @addr_obj = addr_obj
      else
        raise "Invalid call to GeoPoint, unknown object #{addr_obj.inspect}"
      end
      @latitude = 36.20687
      @longitude = -115.27857
      @time_zone_code = '08'
      @resultcodes = ['AS01']
      @is_valid = true
    end
  end
end