require "./spec_helper"

describe MaxMindDB do
  city_db = MaxMindDB.new(db_path("GeoIP2-City-Test"))
  source_data = JSON.parse(File.read(source_path("GeoIP2-City-Test"))).as_a

  source_data.each do |part|
    part.as_h.each do |address, data|
      context "for the ip #{address}" do
        it "returns a MaxMindDB::Any" do
          city_db.get(address).should be_a(MaxMindDB::Any)
        end

        it "found?" do
          city_db.get(address).found?.should be_true
        end

        describe "city" do
          next unless data["city"]?

          city = data["city"].as_h

          it "geoname id" do
            any = city["geoname_id"]
            geoname_id = any.as_s? ? any.as_s.to_i : any.as_i

            city_db.get(address)["city"]["geoname_id"].as_i.should eq(geoname_id)
            city_db.get(address)[:city][:geoname_id].as_i.should eq(geoname_id)
          end

          city["names"].as_h.each do |locale, name|
            it "name (locale: #{locale})" do
              city_db.get(address)["city"]["names"][locale].as_s.should eq(name.as_s)
              city_db.get(address)[:city][:names][locale].as_s.should eq(name.as_s)
            end
          end
        end

        describe "continent" do
          next unless data["continent"]?

          continent = data["continent"].as_h

          it "geoname id" do
            city_db.get(address)["continent"]["geoname_id"].as_i.should eq(continent["geoname_id"].as_i)
            city_db.get(address)[:continent][:geoname_id].as_i.should eq(continent["geoname_id"].as_i)
          end

          it "code" do
            city_db.get(address)["continent"]["code"].as_s.should eq(continent["code"].as_s)
            city_db.get(address)[:continent][:code].as_s.should eq(continent["code"].as_s)
          end

          continent["names"].as_h.each do |locale, name|
            it "name (locale: #{locale})" do
              city_db.get(address)["continent"]["names"][locale].as_s.should eq(name.as_s)
              city_db.get(address)[:continent][:names][locale].as_s.should eq(name.as_s)
            end
          end
        end

        describe "country" do
          next unless data["country"]?

          country = data["country"].as_h

          it "geoname id" do
            city_db.get(address)["country"]["geoname_id"].as_i.should eq(country["geoname_id"].as_i)
            city_db.get(address)[:country][:geoname_id].as_i.should eq(country["geoname_id"].as_i)
          end

          it "ISO code" do
            city_db.get(address)["country"]["iso_code"].as_s.should eq(country["iso_code"])
            city_db.get(address)[:country][:iso_code].as_s.should eq(country["iso_code"])
          end

          country["names"].as_h.each do |locale, name|
            it "name (locale: #{locale})" do
              city_db.get(address)["country"]["names"][locale].as_s.should eq(name.as_s)
              city_db.get(address)[:country][:names][locale].as_s.should eq(name.as_s)
            end
          end
        end

        describe "location" do
          next unless data["location"]?

          location = data["location"].as_h

          it "accuracy radius" do
            any = location["accuracy_radius"]
            accuracy_radius = any.as_s? ? any.as_s.to_i : any.as_i

            city_db.get(address)["location"]["accuracy_radius"].as_i.should eq(accuracy_radius)
            city_db.get(address)[:location][:accuracy_radius].as_i.should eq(accuracy_radius)
          end

          it "latitude" do
            any = location["latitude"]
            latitude = any.as_s? ? any.as_s.to_f : any.as_f

            city_db.get(address)["location"]["latitude"].as_f.should eq(latitude)
            city_db.get(address)[:location][:latitude].as_f.should eq(latitude)
          end

          it "longitude" do
            any = location["longitude"]
            longitude = any.as_s? ? any.as_s.to_f : any.as_f

            city_db.get(address)["location"]["longitude"].as_f.should eq(longitude)
            city_db.get(address)[:location][:longitude].as_f.should eq(longitude)
          end

          if location["time_zone"]?
            it "time zone" do
              city_db.get(address)["location"]["time_zone"].as_s.should eq(location["time_zone"].as_s)
              city_db.get(address)[:location][:time_zone].as_s.should eq(location["time_zone"].as_s)
            end
          end
        end

        describe "registered_country" do
          next unless data["registered_country"]?

          registered_country = data["registered_country"].as_h

          it "geoname id" do
            city_db.get(address)["registered_country"]["geoname_id"].as_i.should eq(registered_country["geoname_id"].as_i)
            city_db.get(address)[:registered_country][:geoname_id].as_i.should eq(registered_country["geoname_id"].as_i)
          end

          it "ISO code" do
            city_db.get(address)["registered_country"]["iso_code"].as_s.should eq(registered_country["iso_code"])
            city_db.get(address)[:registered_country][:iso_code].as_s.should eq(registered_country["iso_code"])
          end

          registered_country["names"].as_h.each do |locale, name|
            it "name (locale: #{locale})" do
              city_db.get(address)["registered_country"]["names"][locale].as_s.should eq(name.as_s)
              city_db.get(address)[:registered_country][:names][locale].as_s.should eq(name.as_s)
            end
          end
        end

        describe "subdivisions" do
          next unless data["subdivisions"]?

          subdivisions = data["subdivisions"].as_a

          subdivisions.each_with_index do |subdivision, index|
            it "geoname id" do
              city_db.get(address)["subdivisions"][index]["geoname_id"].as_i.should eq(subdivision["geoname_id"].as_i)
              city_db.get(address)[:subdivisions][index][:geoname_id].as_i.should eq(subdivision["geoname_id"].as_i)
            end

            it "ISO code" do
              city_db.get(address)["subdivisions"][index]["iso_code"].as_s.should eq(subdivision["iso_code"])
              city_db.get(address)[:subdivisions][index][:iso_code].as_s.should eq(subdivision["iso_code"])
            end

            subdivision["names"].as_h.each do |locale, name|
              it "name (locale: #{locale})" do
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
