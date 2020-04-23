module VersionCake
  class VersionContextService

    def initialize(config)
      puts "inititalizing version context service: #{config.inspect}"
      @versioned_resources = config.versioned_resources
      @default_version = config.missing_version
      @strategies = config.extraction_strategies
    end

    def create_context_from_request(raw_request)
      puts "RAW REQUEST: #{raw_request}"
      return unless resource = find_resource(raw_request.path)

      request = VersionCake::VersionedRequest.new(
                    raw_request,
                    @strategies,
                    @default_version
                )
      request.execute

      result = if request.failed
        :invalid_version
      else
        check_version(resource, request.version)
      end

      VersionCake::VersionContext.new(request.version, resource, result)
    end

    def create_context(uri, version)
      puts "creating context: #{uri.inspect}"
      puts "creating context: #{version.inspect}"
      puts "creating context find_resource: #{find_resource(uri)}"
      return unless resource = find_resource(uri)

      result = check_version(resource, version)
      puts "result? #{result.inspect}"
      VersionCake::VersionContext.new(version, resource, result)
    end

    private

    def check_version(resource, version)
      VersionCake::VersionChecker.new(resource, version).execute
    end

    def find_resource(uri)
      @versioned_resources.find { |resource| resource.uri.match uri }
    end
  end
end
