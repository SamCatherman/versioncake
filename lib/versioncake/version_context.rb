module VersionCake
  class VersionContext
    attr_reader :version, :resource, :result

    def initialize(version, resource, result)
      puts "initializing versionContext #{version}"
      puts "initializing versionContext #{resource}"
      puts "initializing versionContext #{result}"
      @version, @resource, @result = version, resource, result
    end

    # A boolean check to determine if the latest version is requested.
    def is_latest_version?
      @version == @resource.latest_version
    end

    # Ordered versions that are equal to or lower
    # than the requested version.
    def available_versions
      @resource.available_versions.reverse.reject { |v| v > @version }
    end
  end
end