require 'active_support/core_ext/module/attribute_accessors.rb'
require 'active_support/core_ext/array/wrap.rb'

module VersionCake
  class Configuration

    SUPPORTED_VERSIONS_DEFAULT = (1..10)
    VERSION_KEY_DEFAULT = 'api_version'

    attr_reader :extraction_strategies, :supported_version_numbers, :versioned_resources
    attr_accessor :missing_version, :version_key, :rails_view_versioning

    def initialize
      @versioned_resources           = []
      @version_key                   = VERSION_KEY_DEFAULT
      @rails_view_versioning         = true
      self.supported_version_numbers = SUPPORTED_VERSIONS_DEFAULT
      self.extraction_strategy       = [
          :http_accept_parameter,
          :http_header,
          :request_parameter,
          :path_parameter,
          :query_parameter
      ]
    end

    def extraction_strategy=(val)
      @extraction_strategies = []
      Array.wrap(val).each do |configured_strategy|
        @extraction_strategies << VersionCake::ExtractionStrategy.lookup(configured_strategy)
      end
    end

    def supported_version_numbers=(val)
      @supported_version_numbers = val.respond_to?(:to_a) ? val.to_a : Array.wrap(val)
      @supported_version_numbers.sort!.reverse!
    end

    def supported_versions(requested_version_number=nil)
      @supported_version_numbers.collect do |supported_version_number|
        if requested_version_number.nil? || supported_version_number <= requested_version_number
          :"v#{supported_version_number}"
        end
      end
    end

    def supports_version?(version)
      @supported_version_numbers.include? version
    end

    def latest_version
      @supported_version_numbers.first
    end

    def resources
      builder = ResourceBuilder.new
      yield builder
      @versioned_resources = builder.resources
    end
  end

  class ResourceBuilder
    attr_reader :resources
    def initialize
      @resources = []
    end
    def resource(regex, obsolete, unsupported, supported)
      @resources << VersionCake::VersionedResource.new(regex, obsolete, unsupported, supported)
    end
  end
end