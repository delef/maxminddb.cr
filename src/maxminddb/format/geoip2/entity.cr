module MaxMindDB::Format::GeoIP2::Entity
  abstract class Base
    getter data
    def_hash data

    def initialize(@data : Any?)
    end

    def found?
      @data.try &.found?
    end

    def empty?
      @data.try &.empty?
    end

    def inspect(io)
      @data.inspect(io)
    end
  end

  ENTITY_MAP = {
    City               => {geoname_id: Int32, names: Hash},
    Continent          => {geoname_id: Int32, names: Hash, code: String},
    Country            => {geoname_id: Int32, names: Hash, iso_code: String},
    Postal             => {code: String},
    RegisteredCountry  => {geoname_id: Int32, names: Hash, iso_code: String},
    RepresentedCountry => {geoname_id: Int32, names: Hash, iso_code: String},
    Subdivisions       => {geoname_id: Int32, names: Hash, iso_code: String},
    Traits             => {is_anonymous_proxy: Bool, is_satellite_provider: Bool},
    Location           => {accuracy_radius: Int32, latitude: Float64, longitude: Float64,
                           metro_code: Int32, time_zone: String},
  }
  TYPE_SHORTCUTS = {
    Int32 => :as_i,
    Float64 => :as_f,
    String => :as_s,
    Hash => :as_h,
    Array => :as_a,
    Bool => :as_b
  }

  {% for klass, props in ENTITY_MAP %}
    class {{klass}} < Base
      {% for prop_name, prop_type in props %}
        def {{prop_name}}?: Bool
          if data = @data
            data[{{prop_name.stringify}}]? != nil
          else
            false
          end
        end

        {% if prop_name == :names %}
          def names : Hash(String, String)
            result = {} of String => String

            if data = @data
              data["names"].as_h.each { |k, v| result[k] = v.as_s }
            end

            result
          end

          def name(locale = DEFAULT_LOCALE) : String?
            names[locale] if names.has_key? locale
          end
        {% else %}
          def {{prop_name.id}} : {{prop_type}}?
            return unless data = @data
            
            if {{prop_name.id}}?
              data[{{prop_name.stringify}}].{{TYPE_SHORTCUTS[prop_type].id}}
            end
          end
        {% end %}
      {% end %}
    end
  {% end %}
end
