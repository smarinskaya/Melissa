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

    def initialize(opts)
      @is_valid = false
      unless opts.kind_of?(AddrObj) || opts.kind_of?(Hash)
        raise "Invalid call to GeoPoint, unknown object #{opts.inspect}"
      end
      @latitude = 27.850397
      @longitude = -82.659555
      @time_zone_code = '05'
      @resultcodes = ['GS05']
      @is_valid = true
    end
  end
end
