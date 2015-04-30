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

    @@time_zones = {
        '04' => 'Atlantic/Bermuda',
        '05' => 'US/Eastern',
        '06' => 'US/Central',
        '07' => 'US/Mountain',
        '08' => 'US/Pacific',
        '09' => 'US/Alaska',
        '10' => 'US/Hawaii',
        '11' => 'US/Samoa',
        '13' => 'Pacific/Majuro',
        '14' => 'Pacific/Guam',
        '15' => 'Pacific/Palau'
    }

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

    def time_zone_offset
      GeoPoint.time_zone_offset(self.time_zone_code, @addr_obj.state)
    end

    # Hack for AddrObj to share code
    def self.time_zone_offset(time_zone_code, state=nil)
      time_zone = @@time_zones[time_zone_code]
      return nil unless time_zone
      time_zone = 'US/Arizona' if state == 'AZ'
      return Time.now.in_time_zone(time_zone).utc_offset / -60
    end
  end
end


