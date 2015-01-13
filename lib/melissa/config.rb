module Melissa

  MODES = [:mock, :prod]

  class Config

    attr_accessor :mode, :addr_obj_license, :path_to_yml, :path_to_lib

    def initialize
      @mode = :mock
      #we need to initialize to current value, but have the ability to set new one.
      #It means that we need to store it somewhere?? It is public gem, therefore,
      #it should not be clarity database. ini. file

    end
  end
end