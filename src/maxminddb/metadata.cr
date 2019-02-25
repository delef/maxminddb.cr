require "./any"
require "./decoder"

module MaxMindDB
  struct Metadata
    # 
    private METADATA_START_MARKER = "\xAB\xCD\xEFMaxMind.com".to_slice
    
    # The number of nodes in the search tree.
    getter node_count : Int32
    
    # The bit size of a record in the search tree.
    getter record_size : Int32

    # The size of a node in bytes.
    getter node_byte_size : Int32

    # The size of the search tree in bytes.
    getter search_tree_size : Int32

    # The IP version of the data in a database.
    #
    # A value of `4` means the database only supports IPv4.
    # A database with a value of `6` may support both IPv4 and IPv6 lookups.
    getter ip_version : Int32
    
    # A string identifying the database type.
    #
    # ```
    # metadata.database_type # => "GeoIP2-City"
    # ```
    getter database_type : String
    
    # An array of locale codes supported by the database.
    #
    # ```
    # metadata.languages # => ["en", "de", "ru"]
    # ```
    getter languages : Array(String)

    # The Unix epoch for the build time of the database.
    getter build_epoch : Time

    # A hash from locales to text descriptions of the database.
    getter description : Hash(String, String)

    # The major version number for the database's binary format.
    getter binary_format_major_version : Int32

    # The minor version number for the database's binary format.
    getter binary_format_minor_version : Int32

    # MaxMind DB binary format version.
    #
    # ```
    # metadata.version # => "2.0"
    # ```
    getter version : String

    # :nodoc:
    def initialize(buffer : Buffer)
      marker_index = buffer.rindex(METADATA_START_MARKER)

      if marker_index.nil?
        raise InvalidDatabaseException.new(
          "Metadata section not found. Is this a valid MaxMind DB file?"
        )
      end

      start_offset = marker_index + METADATA_START_MARKER.size
      metadata = Decoder.new(buffer, start_offset).decode(start_offset).to_any

      if metadata.empty?
        raise InvalidDatabaseException.new("Metadata is empty")
      end

      @node_count = metadata["node_count"].as_i
      @record_size = metadata["record_size"].as_i
      @node_byte_size = @record_size / 4
      @search_tree_size = @node_count * @node_byte_size
      @ip_version = metadata["ip_version"].as_i

      unless [24, 28, 32].includes?(@record_size)
        raise InvalidDatabaseException.new("Unsupported record size")
      end

      @database_type = metadata["database_type"].as_s
      @description = metadata["description"].as_h.transform_values &.as_s
      @languages = metadata["languages"].as_a.map &.as_s
      @build_epoch = Time.unix(metadata["build_epoch"].as_i)

      @binary_format_major_version = metadata["binary_format_major_version"].as_i
      @binary_format_minor_version = metadata["binary_format_minor_version"].as_i
      @version = "#{@binary_format_major_version}.#{@binary_format_minor_version}"
    end
  end
end
