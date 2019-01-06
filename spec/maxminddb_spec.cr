require "./spec_helper"

describe MaxMindDB do
  city_db = MaxMindDB.new("spec/cache/GeoLite2-City.mmdb")
  country_db = MaxMindDB.new("spec/cache/GeoLite2-Country.mmdb")

  context "for the ip 77.88.77.88 (IPv4)" do
    ip = "77.88.77.88"

    it "returns a MaxMindDB::Any" do
      city_db.lookup(ip).should be_a(MaxMindDB::Any)
    end

    it "found?" do
      city_db.lookup(ip).found?.should be_true
    end

    it "returns Oslo as the English name" do
      city_db.lookup(ip)["city"]["names"]["en"].as_s.should eq("Oslo")
    end

    it "returns Oslo as the English name (symbol keys)" do
      city_db.lookup(ip)[:city][:names][:en].as_s.should eq("Oslo")
    end

    it "returns 10.4907 as the longitude" do
      city_db.lookup(ip)["location"]["longitude"].as_f.should eq(10.4907)
    end

    it "returns 10.4907 as the longitude (symbol keys)" do
      city_db.lookup(ip)[:location][:longitude].as_f.should eq(10.4907)
    end

    it "returns Norway as the English country name" do
      country_db.lookup(ip)["country"]["names"]["en"].as_s.should eq("Norway")
    end

    it "returns Norway as the English country name (symbol keys)" do
      country_db.lookup(ip)[:country][:names][:en].as_s.should eq("Norway")
    end

    it "returns NO as the country iso code" do
      country_db.lookup(ip)["country"]["iso_code"].as_s.should eq("NO")
    end

    it "returns NO as the country iso code (symbol keys)" do
      country_db.lookup(ip)[:country][:iso_code].as_s.should eq("NO")
    end

    context "as a Integer" do
      integer_ip = IPAddress.new(ip).as(IPAddress::IPv4).to_u32

      it "found?" do
        city_db.lookup(integer_ip).found?.should be_true
      end

      it "returns a MaxMindDB::Result" do
        city_db.lookup(integer_ip).should be_a(MaxMindDB::Any)
      end

      it "returns Oslo as the English name" do
        city_db.lookup(integer_ip)["city"]["names"]["en"].as_s.should eq("Oslo")
      end

      it "returns Norway as the English country name" do
        country_db.lookup(integer_ip)["country"]["names"]["en"].as_s.should eq("Norway")
      end
    end
  end

  context "for the ip 2001:708:510:8:9a6:442c:f8e0:7133 (IPv6)" do
    ip = "2001:708:510:8:9a6:442c:f8e0:7133"

    it "found?" do
      city_db.lookup(ip).found?.should be_true
    end

    it "returns FI as the country iso code" do
      country_db.lookup(ip)["country"]["iso_code"].as_s.should eq("FI")
    end

    context "as an integer" do
      integer_ip = IPAddress.new(ip).as(IPAddress::IPv6).to_u128

      it "returns FI as the country iso code" do
        country_db.lookup(ip)["country"]["iso_code"].as_s.should eq("FI")
      end
    end
  end

  context "for the ip 127.0.0.1 (local ip)" do
    ip = "127.0.0.1"

    it "returns a MaxMindDB::Any" do
      city_db.lookup(ip).should be_a(MaxMindDB::Any)
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
      it "returns a MaxMindDB::Any" do
        city_db.lookup(ip).should be_a(MaxMindDB::Any)
      end

      it "returns #{iso} as the country iso code" do
        country_db.lookup(ip)["country"]["iso_code"].as_s.should eq(iso)
      end
    end
  end
end
