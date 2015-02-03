# Fake out Melissa data in Dev and Test environments. For local tests, and for Release and Hotfix
module Melissa
  class AddrObjMock < AddrObj

    # Since we're faking it, create accessors that just return the corresponding opts value except the ones we dummy in the ctor
    @@melissa_attributes.each do |name|
      name = name.underscore
      class_eval <<-EOS
        define_method(:#{name}) do
          @#{name} ||= (@opts[:#{name}] || nil)
        end
      EOS
    end

    #Mock
    def initialize(opts)
      @opts = opts
      #@urbanization        = opts[:urbanization] || ''
      @resultcodes = ['AS01']
      @address_type_string = 'Street'
    end

    #Mock
    def delivery_point_code
      point_code = nil
      point_code = self.zip[3..5] if self.zip.present?
      return point_code
    end

    #Mock
    def delivery_point_check_digit
      self.city && (self.city.sum % 10).to_s
    end

    #Mock
    def plus4
      return '1234'
    end

    #Mock
    def valid?
      #we will mock delivery point if zip code is present.
      return self.zip.present?
    end
  end
end