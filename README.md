# Melissa

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


##Aknowlegments

Configuration pattern is developed based on Brandon Hilkert blog
http://brandonhilkert.com/blog/ruby-gem-configuration-patterns/

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
