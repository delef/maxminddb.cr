require "./spec_helper"

describe MaxMindDB do
  city_db = MaxMindDB.new(db_path("GeoIP2-City-Test"))

  JSON.parse(File.read(source_path("GeoIP2-City-Test"))).as_a.each do |part|
    part.as_h.each do |address, data|
      context "for the ip #{address}" do
        it "returns a MaxMindDB::Any" do
          city_db.get(address).should be_a(MaxMindDB::Any)
        end

        it "found?" do
          city_db.get(address).found?.should be_true
        end

        if "has a country?"
          city_db.get(address).as_h.has_key?("country").should eq(data.as_h.has_key?("country"))
        end

        if data["city"]?
          it "returns #{data["city"]["geoname_id"]} as city geoname id" do
            any = data["city"]["geoname_id"]
            geoname_id = any.as_s? ? any.as_s.to_i : any.as_i

            city_db.get(address)["city"]["geoname_id"].as_i.should eq(geoname_id)
            city_db.get(address)[:city][:geoname_id].as_i.should eq(geoname_id)
          end

          it "returns #{data["city"]["names"]["en"]} as city name (locale: en)" do
            city_db.get(address)["city"]["names"]["en"].as_s.should eq(data["city"]["names"]["en"])
            city_db.get(address)[:city][:names][:en].as_s.should eq(data["city"]["names"]["en"])
          end
        end

        if data["continent"]?
          it "returns #{data["continent"]["geoname_id"]} as continent geoname id" do
            city_db.get(address)["continent"]["geoname_id"].as_i.should eq(data["continent"]["geoname_id"].as_i)
            city_db.get(address)[:continent][:geoname_id].as_i.should eq(data["continent"]["geoname_id"].as_i)
          end

          it "returns #{data["continent"]["names"]["en"]} as continent name (locale: en)" do
            city_db.get(address)["continent"]["names"]["en"].as_s.should eq(data["continent"]["names"]["en"].as_s)
            city_db.get(address)[:continent][:names][:en].as_s.should eq(data["continent"]["names"]["en"].as_s)
          end

          it "returns #{data["continent"]["code"]} as continent code" do
            city_db.get(address)["continent"]["code"].as_s.should eq(data["continent"]["code"])
            city_db.get(address)[:continent][:code].as_s.should eq(data["continent"]["code"])
          end
        end

        if data["country"]?
          it "returns #{data["country"]["geoname_id"]} as country geoname id" do
            city_db.get(address)["country"]["geoname_id"].as_i.should eq(data["country"]["geoname_id"].as_i)
            city_db.get(address)[:country][:geoname_id].as_i.should eq(data["country"]["geoname_id"].as_i)
          end

          it "returns #{data["country"]["names"]["en"]} as country name (locale: en)" do
            city_db.get(address)["country"]["names"]["en"].as_s.should eq(data["country"]["names"]["en"].as_s)
            city_db.get(address)[:country][:names][:en].as_s.should eq(data["country"]["names"]["en"].as_s)
          end

          it "returns #{data["country"]["iso_code"]} as ISO country code" do
            city_db.get(address)["country"]["iso_code"].as_s.should eq(data["country"]["iso_code"])
            city_db.get(address)[:country][:iso_code].as_s.should eq(data["country"]["iso_code"])
          end
        end

        if data["location"]?
          it "returns #{data["location"]["accuracy_radius"]} as location accuracy radius" do
            any = data["location"]["accuracy_radius"]
            accuracy_radius = any.as_s? ? any.as_s.to_i : any.as_i

            city_db.get(address)["location"]["accuracy_radius"].as_i.should eq(accuracy_radius)
            city_db.get(address)[:location][:accuracy_radius].as_i.should eq(accuracy_radius)
          end

          it "returns #{data["location"]["latitude"]} as location latitude" do
            any = data["location"]["latitude"]
            latitude = any.as_s? ? any.as_s.to_f : any.as_f

            city_db.get(address)["location"]["latitude"].as_f.should eq(latitude)
            city_db.get(address)[:location][:latitude].as_f.should eq(latitude)
          end

          it "returns #{data["location"]["longitude"]} as location longitude" do
            any = data["location"]["longitude"]
            longitude = any.as_s? ? any.as_s.to_f : any.as_f

            city_db.get(address)["location"]["longitude"].as_f.should eq(longitude)
            city_db.get(address)[:location][:longitude].as_f.should eq(longitude)
          end

          if data["location"]["time_zone"]?
            it "returns #{data["location"]["time_zone"]} as location time zone" do
              city_db.get(address)["location"]["time_zone"].as_s.should eq(data["location"]["time_zone"].as_s)
              city_db.get(address)[:location][:time_zone].as_s.should eq(data["location"]["time_zone"].as_s)
            end
          end
        end

        if data["registered_country"]?
          it "returns #{data["registered_country"]["geoname_id"]} as registered country geoname id" do
            city_db.get(address)["registered_country"]["geoname_id"].as_i.should eq(data["registered_country"]["geoname_id"].as_i)
            city_db.get(address)[:registered_country][:geoname_id].as_i.should eq(data["registered_country"]["geoname_id"].as_i)
          end

          it "returns #{data["registered_country"]["names"]["en"]} as registered country name (locale: en)" do
            city_db.get(address)["registered_country"]["names"]["en"].as_s.should eq(data["registered_country"]["names"]["en"].as_s)
            city_db.get(address)[:registered_country][:names][:en].as_s.should eq(data["registered_country"]["names"]["en"].as_s)
          end

          it "returns #{data["registered_country"]["iso_code"]} as ISO registered country code" do
            city_db.get(address)["registered_country"]["iso_code"].as_s.should eq(data["registered_country"]["iso_code"])
            city_db.get(address)[:registered_country][:iso_code].as_s.should eq(data["registered_country"]["iso_code"])
          end
        end

        if data["subdivisions"]?
          data["subdivisions"].as_a.each_with_index do |subdivision, index|
            it "returns #{subdivision["geoname_id"]} as subdivision geoname id" do
              city_db.get(address)["subdivisions"][index]["geoname_id"].as_i.should eq(subdivision["geoname_id"].as_i)
              city_db.get(address)[:subdivisions][index][:geoname_id].as_i.should eq(subdivision["geoname_id"].as_i)
            end

            it "returns #{subdivision["names"]["en"]} as subdivision name (locale: en)" do
              city_db.get(address)["subdivisions"][index]["names"]["en"].as_s.should eq(subdivision["names"]["en"].as_s)
              city_db.get(address)[:subdivisions][index][:names][:en].as_s.should eq(subdivision["names"]["en"].as_s)
            end

            it "returns #{subdivision["iso_code"]} as ISO subdivision code" do
              city_db.get(address)["subdivisions"][index]["iso_code"].as_s.should eq(subdivision["iso_code"])
              city_db.get(address)[:subdivisions][index][:iso_code].as_s.should eq(subdivision["iso_code"])
            end
          end
        end
      end
    end
  end
end
