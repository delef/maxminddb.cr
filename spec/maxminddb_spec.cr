require "./spec_helper"

describe MaxMindDB do
  city_db = MaxMindDB.new(db_path("GeoIP2-City-Test"))

  context "for the ip 81.2.69.142" do
    ip = "81.2.69.142"

    it "returns a MaxMindDB::Any" do
      city_db.get(ip).should be_a(MaxMindDB::Any)
    end

    it "found?" do
      city_db.get(ip).found?.should be_true
    end

    it "returns United Kingdom as the English country name" do
      city_db.get(ip)["country"]["names"]["en"].as_s.should eq("United Kingdom")
      city_db.get(ip)[:country][:names][:en].as_s.should eq("United Kingdom")
    end

    it "returns GB as the country iso code" do
      city_db.get(ip)["country"]["iso_code"].as_s.should eq("GB")
      city_db.get(ip)[:country][:iso_code].as_s.should eq("GB")
    end

    it "returns London as the English name" do
      city_db.get(ip)["city"]["names"]["en"].as_s.should eq("London")
      city_db.get(ip)[:city][:names][:en].as_s.should eq("London")
    end

    it "returns 51.5142 as the latitude" do
      city_db.get(ip)["location"]["latitude"].as_f.should eq(51.5142)
      city_db.get(ip)[:location][:latitude].as_f.should eq(51.5142)
    end

    it "returns -0.0931 as the longitude" do
      city_db.get(ip)["location"]["longitude"].as_f.should eq(-0.0931)
      city_db.get(ip)[:location][:longitude].as_f.should eq(-0.0931)
    end
  end

  context "for the ip 2a02:f1c0:510:8:9a6:442c:f8e0:7133 (2a02:f1c0::/29)" do
    ip = "2a02:f1c0:510:8:9a6:442c:f8e0:7133"

    it "found?" do
      city_db.get(ip).found?.should be_true
    end

    it "returns Ukraine as the English country name" do
      city_db.get(ip)["country"]["names"]["en"].as_s.should eq("Ukraine")
      city_db.get(ip)[:country][:names][:en].as_s.should eq("Ukraine")
    end

    it "returns UA as the country iso code" do
      city_db.get(ip)["country"]["iso_code"].as_s.should eq("UA")
      city_db.get(ip)[:country][:iso_code].as_s.should eq("UA")
    end
  end

  context "for the ip 127.0.0.1 (local ip)" do
    ip = "127.0.0.1"

    it "returns a MaxMindDB::Any" do
      city_db.get(ip).should be_a(MaxMindDB::Any)
    end

    it "found?" do
      city_db.get(ip).found?.should be_false
    end
  end

  context "test ips" do
    [
      {"81.2.69.144",   "GB"},
      {"216.160.83.56", "US"},
      {"89.160.20.112", "SE"},
      {"89.160.20.128", "SE"},
      {"67.43.156.0",   "BT"},
      {"202.196.224.0", "PH"},
      {"175.16.199.0",  "CN"},
    ].each do |ip, iso|
      it "returns a MaxMindDB::Any" do
        city_db.get(ip).should be_a(MaxMindDB::Any)
      end

      it "returns #{iso} as the country iso code" do
        city_db.get(ip)["country"]["iso_code"].as_s.should eq(iso)
        city_db.get(ip)[:country][:iso_code].as_s.should eq(iso)
      end
    end
  end
end
