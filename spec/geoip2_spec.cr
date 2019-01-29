require "./spec_helper"

describe MaxMindDB::GeoIP2 do
  city_db = MaxMindDB::GeoIP2.open(db_path("GeoIP2-City-Test"))

  context "for the ip 81.2.69.142" do
    ip = "81.2.69.142"

    it "returns a MaxMindDB::Format::GeoIP2::Root" do
      city_db.get(ip).should be_a(MaxMindDB::Format::GeoIP2::Root)
    end

    it "found?" do
      city_db.get(ip).found?.should be_true
    end

    it "returns Array of Hash(String, String) of country names" do
      city_db.get(ip).country.names.should be_a(Hash(String, String))
    end

    it "returns United Kingdom as the English country name (default locale)" do
      city_db.get(ip).country.name.should eq("United Kingdom")
    end

    it "returns United Kingdom as the English country name" do
      city_db.get(ip).country.name("en").should eq("United Kingdom")
    end

    it "returns United Kingdom as the English country name from Hash" do
      city_db.get(ip).country.names["en"].should eq("United Kingdom")
    end

    it "returns GB as the country iso code" do
      city_db.get(ip).country.iso_code.should eq("GB")
    end

    it "returns Array of Hash(String, String) of city names" do
      city_db.get(ip).city.names.should be_a(Hash(String, String))
    end

    it "returns London as the English name (default locale)" do
      city_db.get(ip).city.name.should eq("London")
    end

    it "returns London as the English name" do
      city_db.get(ip).city.name("en").should eq("London")
    end

    it "returns 10.7461 as the latitude" do
      city_db.get(ip).location.latitude.should eq(51.5142)
    end

    it "returns 10.7461 as the longitude" do
      city_db.get(ip).location.longitude.should eq(-0.0931)
    end
  end

  context "for the ip 2a02:f1c0:510:8:9a6:442c:f8e0:7133 (2a02:f1c0::/29)" do
    ip = "2a02:f1c0:510:8:9a6:442c:f8e0:7133"

    it "found?" do
      city_db.get(ip).found?.should be_true
    end

    it "returns Ukraine as the English country name" do
      city_db.get(ip).country.name.should eq("Ukraine")
      city_db.get(ip).country.name("en").should eq("Ukraine")
    end

    it "returns UA as the country iso code" do
      city_db.get(ip).country.iso_code.should eq("UA")
    end
  end

  context "for the ip 127.0.0.1 (local ip)" do
    ip = "127.0.0.1"

    it "returns a MaxMindDB::Format::GeoIP2::Root" do
      city_db.get(ip).should be_a(MaxMindDB::Format::GeoIP2::Root)
    end

    it "found?" do
      city_db.get(ip).found?.should be_false
    end
  end

  context "test ips" do
    [
      {"81.2.69.144", "GB"},
      {"216.160.83.56", "US"},
      {"89.160.20.112", "SE"},
      {"89.160.20.128", "SE"},
      {"67.43.156.0", "BT"},
      {"202.196.224.0", "PH"},
      {"175.16.199.0", "CN"},
    ].each do |ip, iso|
      it "returns a MaxMindDB::Format::GeoIP2::Root" do
        city_db.get(ip).should be_a(MaxMindDB::Format::GeoIP2::Root)
      end

      it "returns #{iso} as the country iso code" do
        city_db.get(ip).country.iso_code.should eq(iso)
      end
    end
  end
end
