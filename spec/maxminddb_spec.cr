require "./spec_helper"

describe MaxMindDB do
  city_db = MaxMindDB.new(db_path("GeoIP2-City-Test"))
  source = JSON.parse(File.read(source_path("GeoIP2-City-Test"))).as_a

  source.each do |part|
    part.as_h.each do |address, data|
      context "for the ip #{address}" do
        it "returns a MaxMindDB::Any" do
          city_db.get(address).should be_a(MaxMindDB::Any)
        end

        it "found?" do
          city_db.get(address).found?.should be_true
        end

        if data["city"]?
          city = data["city"].as_h

          it "returns #{city["geoname_id"]} as city geoname id" do
            any = city["geoname_id"]
            geoname_id = any.as_s? ? any.as_s.to_i : any.as_i

            city_db.get(address)["city"]["geoname_id"].as_i.should eq(geoname_id)
            city_db.get(address)[:city][:geoname_id].as_i.should eq(geoname_id)
          end

          it "returns #{data["city"]["names"]["en"]} as city name (locale: en)" do
            city_db.get(address)["city"]["names"]["en"].as_s.should eq(city["names"]["en"])
            city_db.get(address)[:city][:names][:en].as_s.should eq(city["names"]["en"])
          end

          city["names"].as_h.each do |locale, name|
            it "returns #{name} as city name (locale: #{locale})" do
              city_db.get(address)["city"]["names"][locale].as_s.should eq(name.as_s)
              city_db.get(address)[:city][:names][locale].as_s.should eq(name.as_s)
            end
          end
        end

        if data["continent"]?
          continent = data["continent"].as_h

          it "returns #{continent["geoname_id"]} as continent geoname id" do
            city_db.get(address)["continent"]["geoname_id"].as_i.should eq(continent["geoname_id"].as_i)
            city_db.get(address)[:continent][:geoname_id].as_i.should eq(continent["geoname_id"].as_i)
          end

          it "returns #{data["continent"]["code"]} as continent code" do
            city_db.get(address)["continent"]["code"].as_s.should eq(continent["code"].as_s)
            city_db.get(address)[:continent][:code].as_s.should eq(continent["code"].as_s)
          end

          data["continent"]["names"].as_h.each do |locale, name|
            it "returns #{name} as continent name (locale: #{locale})" do
              city_db.get(address)["continent"]["names"][locale].as_s.should eq(name.as_s)
              city_db.get(address)[:continent][:names][locale].as_s.should eq(name.as_s)
            end
          end
        end

        if data["country"]?
          country = data["country"].as_h

          it "returns #{country["geoname_id"]} as country geoname id" do
            city_db.get(address)["country"]["geoname_id"].as_i.should eq(country["geoname_id"].as_i)
            city_db.get(address)[:country][:geoname_id].as_i.should eq(country["geoname_id"].as_i)
          end

          it "returns #{data["country"]["iso_code"]} as ISO country code" do
            city_db.get(address)["country"]["iso_code"].as_s.should eq(data["country"]["iso_code"])
            city_db.get(address)[:country][:iso_code].as_s.should eq(data["country"]["iso_code"])
          end

          country["names"].as_h.each do |locale, name|
            it "returns #{name} as country name (locale: #{locale})" do
              city_db.get(address)["country"]["names"][locale].as_s.should eq(name.as_s)
              city_db.get(address)[:country][:names][locale].as_s.should eq(name.as_s)
            end
          end
        end

        if data["location"]?
          location = data["location"].as_h

          it "returns #{location["accuracy_radius"]} as location accuracy radius" do
            any = location["accuracy_radius"]
            accuracy_radius = any.as_s? ? any.as_s.to_i : any.as_i

            city_db.get(address)["location"]["accuracy_radius"].as_i.should eq(accuracy_radius)
            city_db.get(address)[:location][:accuracy_radius].as_i.should eq(accuracy_radius)
          end

          it "returns #{location["latitude"]} as location latitude" do
            any = location["latitude"]
            latitude = any.as_s? ? any.as_s.to_f : any.as_f

            city_db.get(address)["location"]["latitude"].as_f.should eq(latitude)
            city_db.get(address)[:location][:latitude].as_f.should eq(latitude)
          end

          it "returns #{location["longitude"]} as location longitude" do
            any = location["longitude"]
            longitude = any.as_s? ? any.as_s.to_f : any.as_f

            city_db.get(address)["location"]["longitude"].as_f.should eq(longitude)
            city_db.get(address)[:location][:longitude].as_f.should eq(longitude)
          end

          if location["time_zone"]?
            it "returns #{location["time_zone"]} as location time zone" do
              city_db.get(address)["location"]["time_zone"].as_s.should eq(location["time_zone"].as_s)
              city_db.get(address)[:location][:time_zone].as_s.should eq(location["time_zone"].as_s)
            end
          end
        end

        if data["registered_country"]?
          registered_country = data["registered_country"].as_h

          it "returns #{registered_country["geoname_id"]} as registered country geoname id" do
            city_db.get(address)["registered_country"]["geoname_id"].as_i.should eq(registered_country["geoname_id"].as_i)
            city_db.get(address)[:registered_country][:geoname_id].as_i.should eq(registered_country["geoname_id"].as_i)
          end

          it "returns #{registered_country["iso_code"]} as ISO registered country code" do
            city_db.get(address)["registered_country"]["iso_code"].as_s.should eq(registered_country["iso_code"])
            city_db.get(address)[:registered_country][:iso_code].as_s.should eq(registered_country["iso_code"])
          end

          registered_country["names"].as_h.each do |locale, name|
            it "returns #{name} as registered country name (locale: #{locale})" do
              city_db.get(address)["registered_country"]["names"][locale].as_s.should eq(name.as_s)
              city_db.get(address)[:registered_country][:names][locale].as_s.should eq(name.as_s)
            end
          end
        end

        if data["subdivisions"]?
          subdivisions = data["subdivisions"].as_a

          subdivisions.each_with_index do |subdivision, index|
            it "returns #{subdivision["geoname_id"]} as subdivision geoname id" do
              city_db.get(address)["subdivisions"][index]["geoname_id"].as_i.should eq(subdivision["geoname_id"].as_i)
              city_db.get(address)[:subdivisions][index][:geoname_id].as_i.should eq(subdivision["geoname_id"].as_i)
            end

            it "returns #{subdivision["iso_code"]} as ISO subdivision code" do
              city_db.get(address)["subdivisions"][index]["iso_code"].as_s.should eq(subdivision["iso_code"])
              city_db.get(address)[:subdivisions][index][:iso_code].as_s.should eq(subdivision["iso_code"])
            end

            subdivision["names"].as_h.each do |locale, name|
              it "returns #{name} as subdivision name (locale: #{locale})" do
                city_db.get(address)["subdivisions"][index]["names"][locale].as_s.should eq(name.as_s)
                city_db.get(address)[:subdivisions][index][:names][locale].as_s.should eq(name.as_s)
              end
            end
          end
        end
      end
    end
  end
end
