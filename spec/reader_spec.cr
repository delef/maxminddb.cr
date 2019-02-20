require "./spec_helper"

describe MaxMindDB::Reader do
  describe "decoder" do
    reader = MaxMindDB::Reader.new(db_path("MaxMind-DB-test-decoder"))
    record = reader.get("::1.1.1.0")

    it "should be valid basic types" do
      record["boolean"].should eq(MaxMindDB::Any.new(true))
      record["double"].should eq(MaxMindDB::Any.new(42.123456))
      record["float"].should eq(MaxMindDB::Any.new(1.1_f32))
      record["int32"].should eq(MaxMindDB::Any.new(-268_435_456))
      record["uint16"].should eq(MaxMindDB::Any.new(100))
      record["uint32"].should eq(MaxMindDB::Any.new(268_435_456))
      record["uint64"].should eq(MaxMindDB::Any.new(1_152_921_504_606_846_976_u64))
      record["utf8_string"].should eq(MaxMindDB::Any.new("unicode! ☯ - ♫"))
    end

    it "should be valid array" do
      array = [1, 2, 3].map { |i| MaxMindDB::Any.new(i) }
      record["array"].should eq(MaxMindDB::Any.new(array))
    end

    it "should be valid bytes" do
      bytes = [0, 0, 0, 42].map { |i| MaxMindDB::Any.new(i) }
      hex_bytes = [0x00, 0x00, 0x00, 0x2a].map { |i| MaxMindDB::Any.new(i) }

      record["bytes"].should eq(MaxMindDB::Any.new(bytes))
      record["bytes"].should eq(MaxMindDB::Any.new(hex_bytes))
    end

    it "should be valid map" do
      hash = {
        "mapX" => MaxMindDB::Any.new({
          "arrayX" => MaxMindDB::Any.new([
            MaxMindDB::Any.new(7),
            MaxMindDB::Any.new(8),
            MaxMindDB::Any.new(9),
          ]),
          "utf8_stringX" => MaxMindDB::Any.new("hello"),
        }),
      }

      record["map"].should eq(MaxMindDB::Any.new(hash))
    end

    it "should be valid uint128" do
      # Crystal hasn't native support Int128 and UInt128 yet.
      slice = Bytes[1u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8]
      uint128 = slice.reduce(0u128) { |r, v| (r << 8) | v }

      record["uint128"].should eq(MaxMindDB::Any.new(uint128))
    end
  end

  describe "broken files and search trees" do
    it "should behave fine when there is no ipv4 search tree" do
      reader = MaxMindDB::Reader.new(db_path("MaxMind-DB-no-ipv4-search-tree"))

      ["1.1.1.1", "192.1.1.1"].each do |address|
        reader.get(address).should eq(MaxMindDB::Any.new("::0/64"))
      end
    end

    it "should behave fine when search tree is broken" do
      reader = MaxMindDB::Reader.new(db_path("MaxMind-DB-test-broken-search-tree-24"))

      ["1.1.1.1", "1.1.1.2"].each do |address|
        value = Hash(String, MaxMindDB::Any).new
        value["ip"] = MaxMindDB::Any.new(address)

        reader.get(address).should eq(MaxMindDB::Any.new(value))
      end
    end

    it "should raises exception for broken double format" do
      reader = MaxMindDB::Reader.new(db_path("GeoIP2-City-Test-Broken-Double-Format"))

      message = "The MaxMind DB file's data section contains bad data: invalid size of double."
      expect_raises MaxMindDB::InvalidDatabaseException, message do
        reader.get("2001:220::")
      end
    end
  end

  it "should raises exception for missing database" do
    message = "Database not found"
    expect_raises MaxMindDB::InvalidDatabaseException, message do
      MaxMindDB::Reader.new("file-does-not-exist.mmdb")
    end
  end

  it "should raises exception for invalid database" do
    message = "Metadata section not found. Is this a valid MaxMind DB file?"
    expect_raises MaxMindDB::InvalidDatabaseException, message do
      MaxMindDB::Reader.new("README.md")
    end
  end

  describe "various record sizes and ip versions" do
    ips = {
      v4: {
        "1.1.1.3"  => "1.1.1.2",
        "1.1.1.5"  => "1.1.1.4",
        "1.1.1.7"  => "1.1.1.4",
        "1.1.1.9"  => "1.1.1.8",
        "1.1.1.15" => "1.1.1.8",
        "1.1.1.17" => "1.1.1.16",
        "1.1.1.31" => "1.1.1.16",
      },
      v6: {
        "::2:0:1"  => "::2:0:0",
        "::2:0:33" => "::2:0:0",
        "::2:0:39" => "::2:0:0",
        "::2:0:41" => "::2:0:40",
        "::2:0:49" => "::2:0:40",
        "::2:0:52" => "::2:0:50",
        "::2:0:57" => "::2:0:50",
        "::2:0:59" => "::2:0:58",
      },
      mix: {
        "::1.1.1.3" => "::1.1.1.2",
        "::1.1.1.5" => "::1.1.1.4",
        "::1.1.1.7" => "::1.1.1.4",
        "::1.1.1.9" => "::1.1.1.8",
        "::2:0:1"   => "::2:0:0",
        "::2:0:33"  => "::2:0:0",
        "::2:0:39"  => "::2:0:0",
        "::2:0:41"  => "::2:0:40",
      },
    }
    subnets = {
      v4: ["1.1.1.1", "1.1.1.2", "1.1.1.4", "1.1.1.8", "1.1.1.16", "1.1.1.32"],
      v6: ["::1:ffff:ffff", "::2:0:0", "::2:0:40", "::2:0:50", "::2:0:58"],
    }
    not_found = {
      v4: ["1.1.1.33", "255.254.253.123"],
      v6: ["::25:ffff:ffff", "::7:0:0"],
    }

    scenarios = {
      "MaxMind-DB-test-ipv4-24":  ips[:v4],
      "MaxMind-DB-test-ipv4-28":  ips[:v4],
      "MaxMind-DB-test-ipv4-32":  ips[:v4],
      "MaxMind-DB-test-ipv6-24":  ips[:v6],
      "MaxMind-DB-test-ipv6-28":  ips[:v6],
      "MaxMind-DB-test-ipv6-32":  ips[:v6],
      "MaxMind-DB-test-mixed-24": ips[:mix],
      "MaxMind-DB-test-mixed-28": ips[:mix],
      "MaxMind-DB-test-mixed-32": ips[:mix],
    }

    scenarios.each do |file, ips|
      describe "scenario #{file}" do
        reader = MaxMindDB::Reader.new(db_path(file.to_s))
        ip_version = file.to_s.includes?("ipv6") || file.to_s.includes?("mixed") ? 6 : 4
        record_size = file.to_s.split("-").last.to_i

        it "should be valid metadata" do
          reader.metadata.ip_version.should eq(ip_version)
          reader.metadata.node_count.should be > 36
          reader.metadata.record_size.should eq(record_size)
          reader.metadata.build_epoch.should be > Time.unix(1_373_571_901)
          reader.metadata.database_type.should eq("Test")
          reader.metadata.languages.should eq(["en", "zh"])
          reader.metadata.version.should eq("2.0")

          description = {"en" => "Test Database", "zh" => "Test Database Chinese"}
          reader.metadata.description.should eq(description)
        end

        it "should be expected data record" do
          ips.each do |key_address, value_address|
            value = Hash(String, MaxMindDB::Any).new
            value["ip"] = MaxMindDB::Any.new(value_address)

            reader.get(key_address).should eq(MaxMindDB::Any.new(value))
          end
        end

        it "should be expected subnets" do
          key = ip_version == 4 ? :v4 : :v6

          subnets[key].each do |address|
            value = Hash(String, MaxMindDB::Any).new
            value["ip"] = MaxMindDB::Any.new(address)

            reader.get(address).should eq(MaxMindDB::Any.new(value))
          end
        end

        it "should be not found" do
          key = ip_version == 4 ? :v4 : :v6

          not_found[key].each do |address|
            reader.get(address).found?.should be_false
          end
        end
      end
    end
  end
end
