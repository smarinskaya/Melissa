# Melissa

[![Build Status](https://travis-ci.org/smarinskaya/Melissa.svg?branch=master)](https://travis-ci.org/smarinskaya/Melissa)

Configurable interface to Melissa Data Address and GeoCoder objects

##Description

Melissa Gem allows you to use ruby wrappers for Melissa Data's AddrObj and GeoPoint objects or use the mock objects depending on configuration.

Address Object’s functionality is divided into four interfaces, AddressCheck, Parse,
StreetData, and Data. We are using AddressCheck Interface.

The AddressCheck Interface verifies and standardizes your address data using the
most current data from the U. S. Postal Service®. The programming logic used by
AddressCheck is CASS Certified™. This stringent certification ensures the quality of
the data that is passed through the AddressCheck Interface and must be renewed
every year.

The GeoCoder Object enables you to access geographic data using your
ZIP Code™ and optional Plus4. You will be able to obtain latitude and
longitude geographic coordinates, census tract and block numbers, as well as
county name and FIPS numbers.

The Standard version of GeoCoder Object includes GeoPoints 11-digit
(ZIP + 4 + 2) doorstop geolocation data on over 121,827,000 addresses in
the United States.
GeoPoints data is multi-sourced, including interpolated points mathematically
calculated for valid addresses where no GeoPoints data is found, and covers
95 percent of all U.S. delivery addresses, business and residential.


## Installation

Add this line to your application's Gemfile:

    gem 'melissa'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install melissa

## Usage

### Smart Web APIs

#### Property
There is a client included for the property API on Melissa. This requires very little.
You will need two environment variables: `MELISSA_DATA_WEB_SMART_ID`, and `MELISSA_DATA_PROPERTY_API_URL`
Once you have these, you may use the following client. To instantiate a client:

```ruby
irb> client = Melissa::WebSmart::Client.new
irb> client.property(some_fips_code, some_apn) 
# => property data
```

Data comes in the following form:

```json
{
    "record_id": null,
    "result": {
        "code": "YS01,YS03,YC01,GS05",
        "description": "FIPS/APN Match Found. Basic information returned."
    },
    "parcel": {
        "fips_code": "12071",
        "fips_sub_code": null,
        "unformatted_apn": null,
        "apn_sequence_no": null,
        "formatted_apn": "24-43-24-03-00022.0040",
        "original_apn": null,
        "census_tract": null,
        "zoning": null,
        "range": null,
        "township": null,
        "section": null,
        "quarter_section": null,
        "homestead_exempt": null,
        "absentee_owner_code": null,
        "land_use_code": null,
        "county_land_use1": null,
        "county_land_use2": null,
        "property_indicator_code": null,
        "municipality_name": null,
        "view_code": null,
        "location_influence_code": null,
        "number_of_buildings": null
    },
    "property_address": {
        "address": "8351 Bartholomew Dr",
        "city": "North Fort Myers",
        "state": "FL",
        "zip": "33917-1758",
        "address_key": "33917175851",
        "latitude": "26.72156",
        "longitude": "-81.85911"
    },
    "parsed_property_address": {
        "range": "8351",
        "pre_directional": null,
        "street_name": "Bartholomew",
        "suffix": "Dr",
        "post_directional": null,
        "suite_name": null,
        "suite_range": null
    },
    "owner": {
        "corporate_owner": null,
        "name": "EDWARDS JOHN V",
        "name2": null,
        "unparsed_name1": null,
        "unparsed_name2": null,
        "phone": null,
        "phone_opt_out": null
    },
    "owner_address": {
        "address": null,
        "suite": null,
        "city": null,
        "state": null,
        "zip": null,
        "carrier_route": null,
        "matchcode": null,
        "mail_opt_out": null
    },
    "values": {
        "calculated_total_value": "17300",
        "calculated_land_value": null,
        "calculated_improvement_value": null,
        "calculated_total_value_code": null,
        "calculated_land_value_code": null,
        "calculated_improvement_value_code": null,
        "assessed_total_value": "17300",
        "assessed_land_value": null,
        "assessed_improvement_value": null,
        "market_total_value": null,
        "market_land_value": null,
        "market_improvement_value": null,
        "appraised_total_value": null,
        "appraised_land_value": null,
        "appraised_improvement_value": null,
        "tax_amount": "235.82",
        "tax_year": null
    },
    "current_sale": {
        "transaction_id": null,
        "document_year": null,
        "deed_category_code": null,
        "recording_date": null,
        "sale_date": "19920109",
        "sale_price": "69000",
        "sale_code": null,
        "seller_name": null,
        "multi_apn_code": null,
        "multi_apn_count": null,
        "residental_model": null
    },
    "current_deed": {
        "mortgage_amount": "68900",
        "mortgage_date": null,
        "mortgage_loan_type_code": null,
        "mortgage_deed_type_code": null,
        "mortgage_term_code": null,
        "mortgage_term": null,
        "mortgage_due_date": null,
        "mortgage_assumption_amount": null,
        "lender_code": null,
        "lender_name": null,
        "second_mortgage_amount": null,
        "second_mortgage_loan_type_code": null,
        "second_mortgage_deed_type_code": null
    },
    "prior_sale": {
        "transaction_id": null,
        "document_year": null,
        "deed_category_code": null,
        "recording_date": null,
        "sale_date": null,
        "sale_price": null,
        "sale_code": null,
        "transaction_code": null,
        "multi_apn_code": null,
        "multi_apn_count": null,
        "mortgage_amount": null,
        "deed_type_code": null
    },
    "lot": {
        "front_footage": null,
        "depth_footage": null,
        "acreage": "2.1491",
        "square_footage": "93615"
    },
    "square_footage": {
        "universal_building": null,
        "building_area_code": null,
        "building_area": null,
        "living_space": null,
        "ground_floor": null,
        "gross": null,
        "adjusted_gross": null,
        "basement": null,
        "garage_or_parking": null
    },
    "building": {
        "year_built": null,
        "effective_year_built": null,
        "bed_rooms": "0",
        "total_rooms": "0",
        "total_baths_calculated": null,
        "total_baths": "0.00",
        "full_baths": null,
        "half_baths": null,
        "one_quarter_baths": null,
        "three_quarter_baths": null,
        "bath_fixtures": null,
        "air_conditioning_code": null,
        "basement_code": null,
        "building_code": null,
        "improvement_code": null,
        "condition_code": null,
        "construction_code": null,
        "exterior_wall_code": null,
        "fireplace": null,
        "fireplaces": null,
        "fireplace_code": null,
        "foundation_code": null,
        "flooring_code": null,
        "roof_framing_code": null,
        "garage_code": null,
        "heating_code": null,
        "mobile_home": null,
        "parking_spaces": null,
        "parking_code": null,
        "pool": null,
        "pool_code": null,
        "quality_code": null,
        "roof_cover_code": null,
        "roof_type_code": null,
        "stories_code": null,
        "stories": null,
        "building_style_code": null,
        "units": null,
        "electricity_code": null,
        "fuel_code": null,
        "sewer_code": null,
        "water_code": null
    }
}
```

### Base APIs
It is recommended to read the following config options from environment variables
From Melissa Data documentation:
The license string should be entered as an environment variable named
MD_LICENSE. This allows you to update your license string without editing
and recompiling your code

 ```ruby
      self.config_path = ENV['MELISSA_CONFIG_PATH'] if ENV['MELISSA_CONFIG_PATH']
      self.home        = ENV['MELISSA_HOME'] if ENV['MELISSA_HOME']
      @data_path       = ENV['MELISSA_DATA_PATH'] if ENV['MELISSA_DATA_PATH']
      @addr_obj_lib    = ENV['MELISSA_ADDR_OBJ_LIB'] if ENV['MELISSA_ADDR_OBJ_LIB']
      @geo_point_lib   = ENV['MELISSA_GEO_POINT_LIB'] if ENV['MELISSA_GEO_POINT_LIB']
      @license         = ENV['MD_LICENSE'] if ENV['MD_LICENSE']
 ```
It is also possible to set HOME and LICENSE variables in configuration file, which can be accesses

  ```ruby
       Melissa.configure do |config|
         config.config_path = "/etc/config/melissa"
       end
  ```

A suite number can be passed at the end of the values passed to :address
option, or as the parameter of either the :address2 or the :suite option.
If the value passed to the :address option cannot be verified, Address Object
will attempt to verify the value passed via the :address2 option. See Address
Handling in Melissa Data Documentation for more information.
If you use :zip option, :city and :state parameters are optional.
Likewise, if :city and :state are populated, :zip is optional. If possible, it is the
best practice to pass all three values if possible, because Address Object will use
the values to validate each other.

  ```ruby
  #create AddrObj
   valid_addr_obj = ::Melissa.addr_obj(
              address: '9802 Brompton Dr',
              city: 'Tampa',
              state: 'Fl',
              zip: '33626'
          )
   #use it to get deliverypoint
   deliverypoint = valid_addr_obj.delivery_point

   #create GeoPoint Object
   geo_point_obj = ::Melissa.geo_point(valid_addr_obj)
   #use it
   latitude = geo_point_obj.latitude
   longitude= geo_point_obj.longitude
   #or
   geo_point_obj = ::Melissa.geo_point(:zip => 'zip', :plus4 => 'plus4', :delivery_point_code => 'delivery_point_code')

  ```

The calls to Melissa Data library will be attempted only if melissa gem config mode is set to live, and Melissa Data
 library is loaded. This is the default mode for the gem.

```
Melissa.config.mode = :live
```

Otherwise mock objects can be used. This way there is no need to install Melissa Data library on development machine.
The following rules are used in mocking AddrObj Library:
1. if zip_code is present, addres object is valid.
2. to mock delivery point: "#{zip_code}1234#{last 2 digits of zip code}".
   For example, zip_code = 33613     =>    delivery_point = 33613123413

Mocked GeoPoint object will return following values:

```ruby
        @latitude = 27.850397
        @longitude = -82.659555
        @time_zone_code = '05'
        @resultcodes = ['GS05']
        @is_valid = true
```

To use melissa gem from rails application, see railtie.rb, and create melissa.yml in the application, based
on the example below:

```
default:  &defaults
 config_path: /etc/melissa
 mode:        live

production:
  <<:       *defaults

release:
  <<:       *defaults

hotfix:
  <<:       *defaults
```

By using this set up the attempt to call Melissa data library will be made in production, release and hotfix environments,
and mock objects will be used in test and development.

## Meta

* Code: `git clone git://github.com/smarinskaya/melissa.git`
* Home: <https://github.com/smarinskaya/Melissa>
* Bugs: <http://github.com/smarinskaya/Melissa/issues>
* Gems: TODO


## Authors

1. [Brad Pardee](https://github.com/bpardee)
2. [Svetlana Marinskaya](https://github.com/smarinskaya)

## Contributers

1. [ybur-yug](https://github.com/ybur-yug)


##Aknowlegments

Configuration pattern is developed based on Brandon Hilkert blog
http://brandonhilkert.com/blog/ruby-gem-configuration-patterns/

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
