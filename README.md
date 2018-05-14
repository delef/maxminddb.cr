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

```crystal
require "maxminddb"

mmdb = MaxMindDB.new("#{__DIR__}/../data/GeoLite2-Country.mmdb")
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
```

## Contributing

1. Fork it ( https://github.com/delef/geoip2.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [delef](https://github.com/delef) - creator, maintainer