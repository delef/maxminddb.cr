# MaxMindDB.cr

Pure Crystal [MaxMind DB](http://maxmind.github.io/MaxMind-DB/) reader, including the [GeoIP2](http://dev.maxmind.com/geoip/geoip2/downloadable/), which doesn't require [libmaxminddb](https://github.com/maxmind/libmaxminddb).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  maxminddb:
    github: delef/maxminddb.cr
```

## Usage

### GeoIP2
```crystal
require "maxminddb"

mmdb = MaxMindDB::GeoIP2.new("#{__DIR__}/../data/GeoLite2-City.mmdb")
result = mmdb.lookup("1.1.1.1")

result.city.geoname_id # => 2151718
result.city.name "en" # => "Research"
result.city.names # => [{"en" => "Research"}]

result.continent.code # => "OC"
result.continent.geoname_id # => 6255151
result.continent.name "en" # => "Oceania"
result.continent.names # => [{"de" => "Ozeanien"},
                             {"en" => "Oceania"},
                             {"es" => "Oceanía"},
                             {"fr" => "Océanie"},
                             {"ja" => "オセアニア"},
                             {"pt-BR" => "Oceania"},
                             {"ru" => "Океания"},
                             {"zh-CN" => "大洋洲"}]

result.country.iso_code # => "AU"
result.country.geoname_id # => 2077456
result.country.name "en" # => "Australia"
result.country.names # => [{"de" => "Australien"},
                           {"en" => "Australia"},
                           {"es" => "Australia"},
                           {"fr" => "Australie"},
                           {"ja" => "オーストラリア"},
                           {"pt-BR" => "Austrália"},
                           {"ru" => "Австралия"},
                           {"zh-CN" => "澳大利亚"}]

result.location.accuracy_radius # => 1000
result.location.latitude # => -37.7
result.location.longitude # => 145.1833
result.location.time_zone # => "Australia/Melbourne"

result.postal.code # => "3095"
result.registered_country.iso_code # => nil
result.registered_country.geoname_id # => nil
result.registered_country.names # => nil
result.registered_country.name "en" # => nil

result.subdivisions[0].iso_code # => "VIC"
result.subdivisions[0].geoname_id # => 2145234
result.subdivisions[0].name "en" # => "Victoria"
result.subdivisions[0].names # => [{"en" => "Victoria"},
                                   {"pt-BR" => "Vitória"},
                                   {"ru" => "Виктория"}]
```

### any other MaxMind Database

```crystal
require "maxminddb"

mmdb = MaxMindDB.new("#{__DIR__}/../data/GeoLite2-City.mmdb")
result = mmdb.lookup("1.1.1.1")

result["city"]["geoname_id"].as_i # => 2151718
result["city"]["names"]["en"].as_s # => "Research"

result["continent"]["code"].as_s # => "OC"
result["continent"]["geoname_id"].as_i # => 6255151
result["continent"]["names"]["en"].as_s # => "Oceania"

result["country"]["iso_code"].as_s # => "AU"
result["country"]["geoname_id"].as_i # => 2077456
result["country"]["names"]["en"].as_s # => "Australia"

result["location"]["accuracy_radius"].as_i # => 1000
result["location"]["latitude"].as_f # => -37.7
result["location"]["longitude"].as_f # => 145.1833
result["location"]["time_zone"].as_s # => "Australia/Melbourne"

result["postal"]["code"].as_s # => "3095"

result["registered_country"]["iso_code"].as_s # => "AU"
result["registered_country"]["geoname_id"].as_i # => 2077456
result["registered_country"]["names"]["en"].as_s # => "Australia"

result["subdivisions"][0]["iso_code"].as_s # => "VIC"
result["subdivisions"][0]["geoname_id"].as_i # => 2145234
result["subdivisions"][0]["names"]["en"].as_s # => "Victoria"
```

## Contributing

1. Fork it ( https://github.com/delef/maxminddb.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [delef](https://github.com/delef) - creator, maintainer
