require "git"

module Pipefitter
  class StructureBuilder
    def initialize(branch:)
      @branch = branch
    end

    def run
      setup_branch
      checkout_master_structure
      build
      stage
      if changed?
        create_new_branch
        commit
        push
      end
    end

    def changed?
      git.diff.any? { |file| file.path == structure_file }
    end

    def new_branch
      branch + "_pipefitter_structure"
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
      git.checkout_file("master", structure_file)
    end

    def build
      Dir.chdir("repos/loft_hunter") do
        Bundler.with_clean_env do
          system("bundle install")
          system("bin/rake db:drop db:create db:structure:load db:migrate")
        end
      end
    end

    def stage
      git.add(structure_file)
    end

    def create_new_branch
      git.branch(new_branch).checkout
    end

    def commit
      git.commit("Pipefitter updated structure at #{Time.now}")
    end

    def push
      git.push("origin", new_branch)
    end

    def structure_file
      "db/structure.sql"
    end
  end
end
