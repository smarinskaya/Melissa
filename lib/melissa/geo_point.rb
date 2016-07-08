require "melissa/config"

module Melissa
  class GeoPoint
    @@melissa_attributes = %w(
    Latitude
    Longitude
    CensusTract
    CensusBlock
    CountyFips
    CountyName
    PlaceCode
    PlaceName
    TimeZoneCode
    TimeZone
    CBSACode
    CBSATitle
    CBSALevel
    CBSADivisionCode
    CBSADivisionTitle
    CBSADivisionLevel
  )

    @@codes = {
        'GS01' => 'Record was coded to the ZIP + 4 centroid (U.S.) or or the full 6-digit Postal Code level (Canada).',
        'GS02' => 'Record was coded to the ZIP + 2 centroid.',
        'GS03' => 'Record was coded to the 5-digit ZIP Code centroid (U.S.) or or the first 3-digit Postal Code level (Canada).',
        'GS05' => 'Record was coded to rooftop level.(Available On-Premise only)',
        'GS06' => 'Record was coded to interpolated rooftop level.(Available On-Premise only)*',
        'GE01' => 'ZIP Code Error. An invalid ZIP Code was entered.',
        'GE02' => 'ZIP Code not found. The submitted ZIP Code was not found in the database.',
        'GE03' => 'Demo Mode. GeoCoder Object is in Demo Mode and a ZIP Code outside the demo range was detected.',
        'GE04' => 'The GeoCoder Object data files are expired. Please update with the latest data files.',
        'GE05' => 'Geocoding for the country of input record is disabled for your license. Please contact your sales representative to enable.',
    }

    # See http://www.melissadata.com/lookups/resultcodes.asp
    @@good_codes = ['GS01', 'GS02', 'GS03', 'GS05', 'GS06']
    #@@bad_codes   = ['GE01', 'GE02']
    @@fatal_codes = ['GE03', 'GE04', 'GE05']

    @@callbacks = Concurrent::Array.new

    # Allow callbacks to intercept response and perform whatever misc stuff (hint: victim_statements)
    def self.add_callback(&callback)
      @@callbacks << callback
    end

    def valid?
      # Make sure there is at least 1 good code
      @is_valid
    end

    #Added this method to have an ability to stub latitude if needed
    def latitude
      @latitude
    end

    #Added this method to have an ability to stub longitude if needed
    def longitude
      @longitude
    end

    def time_zone_offset(state=nil)
      time_zone = TIME_ZONES[self.time_zone_code]
      return nil unless time_zone
      time_zone = 'US/Arizona' if state == 'AZ'
      return Time.now.in_time_zone(time_zone).utc_offset / -60
    end
  end
end


