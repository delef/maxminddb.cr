require "./spec_helper"

describe MaxMindDB::Decoder do
  decoding = ->(bytes : Bytes) do
    buffer = MaxMindDB::Buffer.new(bytes)

    pointer_base = 0
    offset = 0
    
    decoder = MaxMindDB::Decoder.new(buffer, pointer_base, pointer_test: true)
    decoder.decode(offset).value
  end

  context "should be valid" do
    it "array" do
      {
        "\x00\x04" => [] of MaxMindDB::Any,
        "\x01\x04\x43\x46\x6f\x6f" => [
          MaxMindDB::Any.new("Foo")
        ],
        "\x02\x04\x43\x46\x6f\x6f" +
        "\x43\xe4\xba\xba" => [
          MaxMindDB::Any.new("Foo"),
          MaxMindDB::Any.new("人")
        ]
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(result)
      end
    end

    it "booleans" do
      {
        "\x00\x07" => false,
        "\x01\x07" => true
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(result)
      end
    end

    it "bytes" do
      {
        "\x00\x07" => false,
        "\x01\x07" => true
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(result)
      end
    end

    it "doubles" do
      {
        "\x68\x00\x00\x00\x00\x00\x00\x00\x00" => 0.0_f64,
        "\x68\x3F\xE0\x00\x00\x00\x00\x00\x00" => 0.5,
        "\x68\x40\x09\x21\xFB\x54\x44\x2E\xEA" => 3.14159265359_f64,
        "\x68\x40\x5E\xC0\x00\x00\x00\x00\x00" => 123.0_f64,
        "\x68\x41\xD0\x00\x00\x00\x07\xF8\xF4" => 1_073_741_824.12457_f64,
        "\x68\xBF\xE0\x00\x00\x00\x00\x00\x00" => -0.5_f64,
        "\x68\xC0\x09\x21\xFB\x54\x44\x2E\xEA" => -3.14159265359_f64,
        "\x68\xC1\xD0\x00\x00\x00\x07\xF8\xF4" => -1_073_741_824.12457_f64,
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(result)
      end
    end

    it "floats" do
      {
        "\x04\x08\x00\x00\x00\x00" => 0.0_f32,
        "\x04\x08\x3F\x80\x00\x00" => 1.0_f32,
        "\x04\x08\x3F\x8C\xCC\xCD" => 1.1_f32,
        "\x04\x08\x40\x48\xF5\xC3" => 3.14_f32,
        "\x04\x08\x46\x1C\x3F\xF6" => 9999.99_f32,
        "\x04\x08\xBF\x80\x00\x00" => -1.0_f32,
        "\x04\x08\xBF\x8C\xCC\xCD" => -1.1_f32,
        "\x04\x08\xC0\x48\xF5\xC3" => -3.14_f32,
        "\x04\x08\xC6\x1C\x3F\xF6" => -9999.99_f32
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(result)
      end
    end

    it "int32" do
      {
        "\x00\x01" => 0,
        "\x04\x01\xff\xff\xff\xff" => -1,
        "\x01\x01\xff" => 255,
        "\x04\x01\xff\xff\xff\x01" => -255,
        "\x02\x01\x01\xf4" => 500,
        "\x04\x01\xff\xff\xfe\x0c" => -500,
        "\x02\x01\xff\xff" => 65_535,
        "\x04\x01\xff\xff\x00\x01" => -65_535,
        "\x03\x01\xff\xff\xff" => 16_777_215,
        "\x04\x01\xff\x00\x00\x01" => -16_777_215,
        "\x04\x01\x7f\xff\xff\xff" => 2_147_483_647,
        "\x04\x01\x80\x00\x00\x01" => -2_147_483_647,
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(result)
      end
    end

    it "map" do
      record_size = "\x1C" # 28_u8

      {
        "\xe0" => {} of String => MaxMindDB::Any,
        "\xe1\x42\x65\x6e\x43\x46\x6f\x6f" => MaxMindDB::Any.new({
          "en" => MaxMindDB::Any.new("Foo")
        }),
        "\xe2\x42\x65\x6e\x43\x46\x6f\x6f\x42\x7a" +
        "\x68\x43\xe4\xba\xba" => MaxMindDB::Any.new({
          "en" => MaxMindDB::Any.new("Foo"),
          "zh" => MaxMindDB::Any.new("人")
        }),
        "\xe1\x44\x6e\x61\x6d\x65\xe2\x42\x65\x6e" +
        "\x43\x46\x6f\x6f\x42\x7a\x68\x43\xe4\xba\xba" => MaxMindDB::Any.new({
          "name" => MaxMindDB::Any.new({
            "en" => MaxMindDB::Any.new("Foo"),
            "zh" => MaxMindDB::Any.new("人")
          })
        }),
        "\xe1\x49\x6c\x61\x6e\x67\x75\x61\x67\x65\x73" +
        "\x02\x04\x42\x65\x6e\x42\x7a\x68" => MaxMindDB::Any.new({
          "languages" => MaxMindDB::Any.new([
            MaxMindDB::Any.new("en"),
            MaxMindDB::Any.new("zh")
          ])
        }),
        "\xe9" +
        # node_count => 0
        "\x4anode_count\xc0" +
        # record_size => 28 would be \xa1\x1c
        "\x4brecord_size\xa1" + record_size +
        # ip_version => 4
        "\x4aip_version\xa1\x04" +
        # database_type => "test"
        "\x4ddatabase_type\x44test" +
        # languages => ["en"]
        "\x49languages\x01\x04\x42en" +
        # binary_format_major_version => 2
        "\x5bbinary_format_major_version\xa1\x02" +
        # binary_format_minor_version => 0
        "\x5bbinary_format_minor_version\xa0" +
        # build_epoch => 0
        "\x4bbuild_epoch\x00\x02" +
        # description => "hi"
        "\x4bdescription\x42hi" => MaxMindDB::Any.new({
          "node_count" => MaxMindDB::Any.new(0),
          "record_size" => MaxMindDB::Any.new(28),
          "ip_version" => MaxMindDB::Any.new(4),
          "database_type" => MaxMindDB::Any.new("test"),
          "languages" => MaxMindDB::Any.new([
            MaxMindDB::Any.new("en")
          ]),
          "binary_format_major_version" => MaxMindDB::Any.new(2),
          "binary_format_minor_version" => MaxMindDB::Any.new(0),
          "build_epoch" => MaxMindDB::Any.new(0),
          "description" => MaxMindDB::Any.new("hi"),
        })
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(result)
      end
    end

    it "pointers" do
      {
        "\x20\x00" => 0,
        "\x20\x05" => 5,
        "\x20\x0a" => 10,
        "\x23\xff" => 1023,
        "\x28\x03\xc9" => 3017,
        "\x2f\xf7\xfb" => 524_283,
        "\x2f\xff\xff" => 526_335,
        "\x37\xf7\xf7\xfe" => 134_217_726,
        "\x37\xff\xff\xff" => 134_744_063,
        "\x38\x7f\xff\xff\xff" => 2_147_483_647
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(result)
      end
    end

    it "strings" do
      {
        "\x40" => "",
        "\x41\x31" => "1",
        "\x43\xE4\xBA\xBA" => "人",
        "\x5b\x31\x32\x33\x34" +
        "\x35\x36\x37\x38\x39\x30\x31\x32\x33\x34\x35" +
        "\x36\x37\x38\x39\x30\x31\x32\x33\x34\x35\x36\x37" =>
          "123456789012345678901234567",
        "\x5c\x31\x32\x33\x34" +
        "\x35\x36\x37\x38\x39\x30\x31\x32\x33\x34\x35" +
        "\x36\x37\x38\x39\x30\x31\x32\x33\x34\x35\x36" +
        "\x37\x38" => "1234567890123456789012345678",
        "\x5d\x00\x31\x32\x33" +
        "\x34\x35\x36\x37\x38\x39\x30\x31\x32\x33\x34" +
        "\x35\x36\x37\x38\x39\x30\x31\x32\x33\x34\x35" +
        "\x36\x37\x38\x39" => "12345678901234567890123456789",
        "\x5d\x01\x31\x32\x33" +
        "\x34\x35\x36\x37\x38\x39\x30\x31\x32\x33\x34" +
        "\x35\x36\x37\x38\x39\x30\x31\x32\x33\x34\x35" +
        "\x36\x37\x38\x39\x30" => "123456789012345678901234567890",
        "\x5e\x00\xd7" + "\x78" * 500 => "x" * 500,
        "\x5e\x06\xb3" + "\x78" * 2000 => "x" * 2000,
        "\x5f\x00\x10\x53" + "\x78" * 70_000 => "x" * 70_000,
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(MaxMindDB::Any.new(result))
      end
    end

    it "uint16" do
      {
        "\xa0" => 0,
        "\xa1\xff" => 255,
        "\xa2\x01\xf4" => 500,
        "\xa2\x2a\x78" => 10_872,
        "\xa2\xff\xff" => 65_535,
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(result)
      end
    end

    it "uint32" do
      {
        "\xc0" => 0,
        "\xc1\xff" => 255,
        "\xc2\x01\xf4" => 500,
        "\xc2\x2a\x78" => 10_872,
        "\xc2\xff\xff" => 65_535,
        "\xc3\xff\xff\xff" => 16_777_215,
        "\xc4\xff\xff\xff\xff" => 4_294_967_295,
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(result)
      end
    end

    it "uint64" do
      {
        "\x00\x02" => 0u64,
        "\x01\x02\xff" => 255u64,
        "\x02\x02\x01\xf4" => 500u64,
        "\x02\x02\x2a\x78" => 10872u64,
        "\x02\x02\xff\xff" => 65535u64,
        "\x03\x02\xff\xff\xff" => 16777215u64,
        "\x04\x02\xff\xff\xff\xff" => 4294967295u64,
        "\x05\x02\xff\xff\xff\xff\xff" =>
          1099511627775u64,
        "\x06\x02\xff\xff\xff\xff\xff\xff" =>
          281474976710655u64,
        "\x07\x02\xff\xff\xff\xff\xff\xff\xff" =>
          72057594037927935u64,
        "\x08\x02\xff\xff\xff\xff\xff\xff\xff\xff" =>
          18446744073709551615u64
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(result)
      end
    end

    it "uint128" do
      {
        "\x00\x03" => 0u128,
        "\x01\x03\xff" => 255u128,
        "\x02\x03\x01\xf4" => 500u128,
        "\x02\x03\x2a\x78" => 10872u128,
        "\x02\x03\xff\xff" => 65535u128,
        "\x03\x03\xff\xff\xff" => 16777215u128,
        "\x04\x03\xff\xff\xff\xff" => 4294967295u128,
        "\x05\x03\xff\xff\xff\xff\xff" =>
          1099511627775u128,
        "\x06\x03\xff\xff\xff\xff\xff\xff" =>
          281474976710655u128,
        "\x07\x03\xff\xff\xff\xff\xff\xff\xff" =>
          72057594037927935u128,
        "\x08\x03\xff\xff\xff\xff\xff\xff\xff\xff" =>
          18446744073709551615u128,

        # Crystal hasn't native support Int128 and UInt128 yet
        "\x09\x03\xff\xff\xff\xff\xff\xff\xff\xff\xff" =>
          IO::ByteFormat::BigEndian.decode(UInt128, Bytes[
            0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255
          ]),
        "\x0a\x03\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff" =>
          IO::ByteFormat::BigEndian.decode(UInt128, Bytes[
            0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
          ]),
        "\x0b\x03\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff" =>
          IO::ByteFormat::BigEndian.decode(UInt128, Bytes[
            0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
          ]),
        "\x0c\x03\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff" =>
          IO::ByteFormat::BigEndian.decode(UInt128, Bytes[
            0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
          ]),
        "\x0d\x03\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff" =>
          IO::ByteFormat::BigEndian.decode(UInt128, Bytes[
            0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
          ]),
        "\x0e\x03\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff" =>
          IO::ByteFormat::BigEndian.decode(UInt128, Bytes[
            0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
          ]),
        "\x0f\x03\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff" =>
          IO::ByteFormat::BigEndian.decode(UInt128, Bytes[
            0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
          ]),
        "\x10\x03\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff" =>
          IO::ByteFormat::BigEndian.decode(UInt128, Bytes[
            255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
          ]),
      }.each do |source, result|
        decoding.call(source.to_slice).should eq(result)
      end
    end
  end
end
