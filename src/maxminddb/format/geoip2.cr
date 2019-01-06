module MaxMindDB::Format::GeoIP2
  DEFAULT_LOCALE = "en"

  module Helper
    getter value
    def_hash value

    def found?
      @value.try &.found?
    end

    def empty?
      @value.try &.empty?
    end

    def inspect(io)
      @value.inspect(io)
    end
  end

  module Entity
    STRUCT_MAP = {
      City               => {geoname_id: Int32, names: Hash},
      Continent          => {geoname_id: Int32, names: Hash, code: String},
      Country            => {geoname_id: Int32, names: Hash, iso_code: String},
      Postal             => {code: String},
      RegisteredCountry  => {geoname_id: Int32, names: Hash, iso_code: String},
      RepresentedCountry => {geoname_id: Int32, names: Hash, iso_code: String},
      Subdivision        => {geoname_id: Int32, names: Hash, iso_code: String},
      Traits             => {is_anonymous_proxy: Bool, is_satellite_provider: Bool},
      Location           => {accuracy_radius: Int32, latitude: Float64, longitude: Float64,
                             metro_code: Int32, time_zone: String},
    }
    TYPE_MAP = {
      Int32 => :as_i,
      Float64 => :as_f,
      String => :as_s,
      Hash => :as_h,
      Bool => :as_b
    }
  
    {% for entity_struct, props in STRUCT_MAP %}
      struct {{entity_struct}}
        include Helper

        def initialize(@value : Any?)
        end

        {% for prop_name, prop_type in props %}
          def {{prop_name}}?: Bool
            value = @value
            value && value[{{prop_name.stringify}}]? != nil
          end
  
          {% if prop_name == :names %}
            def names : Hash(String, String)
              result = {} of String => String
  
              if value = @value
                value["names"].as_h.each { |k, v| result[k] = v.as_s }
              end
  
              result
            end
  
            def name(locale : String|Symbol = DEFAULT_LOCALE) : String?
              names[locale.to_s] if names.has_key? locale
            end
          {% else %}
            def {{prop_name.id}} : {{prop_type}}?
              value = @value
              
              if value && value[{{prop_name.stringify}}]?
                value[{{prop_name.stringify}}].{{TYPE_MAP[prop_type].id}}
              end
            end
          {% end %}
        {% end %}
      end
    {% end %}
  end

  struct Root
    include Helper

    def initialize(@value : Any)
    end

    def connection_type? : Bool
      @value.as_h.has_key? "connection_type"
    end

    def connection_type : String?
      @value["connection_type"].as_s if connection_type?
    end

    def subdivisions? : Bool
      @value.as_h.has_key?("subdivisions") && @value["subdivisions"].size > 0
    end

    def subdivisions : Array(Entity::Subdivision)
      subdivisions = [] of Entity::Subdivision

      if subdivisions?
        @value["subdivisions"].as_a.each_index do |i|
          subdivisions << Entity::Subdivision.new(@data["subdivisions"][i]?)
        end
      end

      subdivisions
    end

    ENTITIES = [
      City,
      Continent,
      Country,
      Location,
      Postal,
      RegisteredCountry,
      RepresentedCountry,
      Traits
    ]

    {% for entity_struct in ENTITIES %}
      {% entity_name = entity_struct.stringify.underscore %}

      def {{entity_name.id}}? : Bool
        @value.as_h.has_key? {{entity_name}}
      end

      def {{entity_name.id}} : Entity::{{entity_struct}}?
        Entity::{{entity_struct}}.new(@value[{{entity_name}}]?)
      end
    {% end %}
  end

  def self.new(data : Any)
    Root.new(data)
  end
end
