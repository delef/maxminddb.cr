require "./spec_helper"

describe MaxMindDB do
  city_db = MaxMindDB.open(db_path("GeoIP2-City-Test"))

  describe "metadata" do
    it "ip_version" do
      city_db.metadata.ip_version.should be_a(Int32)
    end

    it "node_count" do
      city_db.metadata.node_count.should be_a(Int32)
    end

    it "record_size" do
      city_db.metadata.record_size.should be_a(Int32)
    end

    it "build_time" do
      city_db.metadata.build_time.should be_a(Time)
    end

    it "database_type" do
      city_db.metadata.database_type.should be_a(String)
    end

    it "description" do
      city_db.metadata.description.should be_a(Hash(String, String))
    end

    it "languages" do
      city_db.metadata.languages.should be_a(Array(String))
    end

    it "node_byte_size" do
      city_db.metadata.node_byte_size.should be_a(Int32)
    end

    it "search_tree_size" do
      city_db.metadata.search_tree_size.should be_a(Int32)
    end

    it "record_byte_size" do
      city_db.metadata.record_byte_size.should be_a(Int32)
    end

    it "tree_depth" do
      city_db.metadata.tree_depth.should be_a(Int32)
    end

    it "version" do
      city_db.metadata.version.should be_a(String)
    end
  end
end
