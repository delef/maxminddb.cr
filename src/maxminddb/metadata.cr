require "./any"
require "./decoder"

module MaxMindDB
  struct Metadata
    private METADATA_START_MARKER = "\xAB\xCD\xEFMaxMind.com".to_slice

    getter ip_version : Int32, node_count : Int32, record_size : Int32,
      build_epoch : Time, database_type : String, languages : Array(String),
      description : Hash(String, String), node_byte_size : Int32,
      search_tree_size : Int32, record_byte_size : Int32, version : String

    def initialize(buffer : Buffer)
      metadata_index = buffer.rindex(METADATA_START_MARKER)

      if metadata_index.nil?
        raise InvalidDatabaseException.new(
          "Metadata section not found. Is this a valid MaxMind DB file?"
        )
      end

      start_offset = metadata_index + METADATA_START_MARKER.size
      metadata = Decoder.new(buffer, start_offset).decode(start_offset).to_any

      if metadata.empty?
        raise InvalidDatabaseException.new("Metadata is empty")
      end

      @ip_version = metadata["ip_version"].as_i
      @node_count = metadata["node_count"].as_i
      @record_size = metadata["record_size"].as_i

      unless [24, 28, 32].includes?(@record_size)
        raise InvalidDatabaseException.new("Unsupported record size")
      end

      @build_epoch = Time.unix(metadata["build_epoch"].as_i)
      @database_type = metadata["database_type"].as_s
      @description = metadata["description"].as_h.transform_values &.as_s
      @languages = metadata["languages"].as_a.map &.as_s

      @node_byte_size = @record_size / 4
      @search_tree_size = @node_count * @node_byte_size
      @record_byte_size = @node_byte_size / 2

      @version = [
        metadata["binary_format_major_version"].as_i,
        metadata["binary_format_minor_version"].as_i,
      ].join('.')
    end
  end
end
