require "git"

module Pipefitter
  class StructureBuilder
    def initialize(branch:)
      @branch = branch
    end

    def self.run(branch:)
      new(branch: branch).run
    end

    def run

    end

    private

    def git
      @git ||= Git.open(File.join("repos", "procore"))
    end
  end
end
