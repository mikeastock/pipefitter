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
      setup_branch
      checkout_master_structure
      build_structure
      create_new_branch
      commit_structure
    end

    private

    attr_reader :branch

    def git
      @git ||= Git.open(File.join("repos", "procore"))
    end

    def setup_branch
      git.fetch
      git.reset_hard
      git.checkout(branch)
      git.pull("origin", branch)
    end

    def checkout_master_structure
      git.checkout_file("master", "db/structure.sql")
    end

    def build_structure
      Bundler.with_clean_env do
        system("bundle install")
        system("bin/rake db:drop db:create db:structure:load db:migrate")
      end
    end

    def create_new_branch
      git.branch(new_branch).checkout
    end

    def commit_structure
      git.add("db/structure.sql")
      git.commit("Pipefitter updated structure at #{Time.now}")
    end

    def new_branch
      branch + "_pipefitter_structure"
    end
  end
end
