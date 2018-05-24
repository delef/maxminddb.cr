require "./spec_helper"

describe MaxMindDB::GeoIP2 do
  city_db = MaxMindDB::GeoIP2.new("spec/cache/GeoLite2-City.mmdb")
  country_db = MaxMindDB::GeoIP2.new("spec/cache/GeoLite2-Country.mmdb")

  context "for the ip 77.88.55.88 (IPv4)" do
    ip = "74.125.225.224"

    it "returns a MaxMindDB::Format::GeoIP2::Root" do
      city_db.lookup(ip).should be_a(MaxMindDB::Format::GeoIP2::Root)
    end

    it "found?" do
      city_db.lookup(ip).found?.should be_true
    end

    it "returns Array of Hash(String, String) of city names" do
      city_db.lookup(ip).city.names.should be_a(Array(Hash(String, String)))
    end

    it "returns Alameda as the English name" do
      city_db.lookup(ip).city.name("en").should eq("Alameda")
    end

    it "returns -122.2788 as the longitude" do
      city_db.lookup(ip).location.longitude.should eq(-122.2788)
    end

    it "returns Array of Hash(String, String) of country names" do
      country_db.lookup(ip).country.names.should be_a(Array(Hash(String, String)))
    end

    it "returns United States as the English country name" do
      country_db.lookup(ip).country.name("en").should eq("United States")
    end

    it "returns US as the country iso code" do
      country_db.lookup(ip).country.iso_code.should eq("US")
    end

    context "as a Integer" do
      ip = IPAddress.new(ip).as(IPAddress::IPv4).to_u32

      it "returns a MaxMindDB::Format::GeoIP2::Root" do
        city_db.lookup(ip).should be_a(MaxMindDB::Format::GeoIP2::Root)
      end

      it "found?" do
        city_db.lookup(ip).found?.should be_true
      end

      it "returns Array of Hash(String, String) of city names" do
        city_db.lookup(ip).city.names.should be_a(Array(Hash(String, String)))
      end

      it "returns Alameda as the English name" do
        city_db.lookup(ip).city.name("en").should eq("Alameda")
      end

      it "returns Array of Hash(String, String) of country names" do
        country_db.lookup(ip).country.names.should be_a(Array(Hash(String, String)))
      end

      it "returns United States as the English country name" do
        country_db.lookup(ip).country.name("en").should eq("United States")
      end
    end
  end

  context "for the ip 2001:708:510:8:9a6:442c:f8e0:7133 (IPv6)" do
    ip = "2001:708:510:8:9a6:442c:f8e0:7133"

    it "found?" do
      city_db.lookup(ip).found?.should be_true
    end

    it "returns FI as the country iso code" do
      country_db.lookup(ip).country.iso_code.should eq("FI")
    end

    context "as an integer" do
      ip = IPAddress.new(ip).as(IPAddress::IPv6).to_u128

      it "returns FI as the country iso code" do
        country_db.lookup(ip).country.iso_code.should eq("FI")
      end
    end
  end

  context "for the ip 127.0.0.1 (local ip)" do
    ip = "127.0.0.1"

    it "returns a MaxMindDB::Format::GeoIP2::Root" do
      city_db.lookup(ip).should be_a(MaxMindDB::Format::GeoIP2::Root)
    end

    it "found?" do
      city_db.lookup(ip).found?.should be_false
    end
  end

  context "test ips" do
    [
      {"185.23.124.1", "SA"},
      {"178.72.254.1", "CZ"},
      {"95.153.177.210", "RU"},
      {"200.148.105.119", "BR"},
      {"195.59.71.43", "GB"},
      {"179.175.47.87", "BR"},
      {"202.67.40.50", "ID"},
    ].each do |ip, iso|
      it "returns a MaxMindDB::Format::GeoIP2::Root" do
        city_db.lookup(ip).should be_a(MaxMindDB::Format::GeoIP2::Root)
      end

      it "returns #{iso} as the country iso code" do
        country_db.lookup(ip).country.iso_code.should eq(iso)
      end
    end
  end
end