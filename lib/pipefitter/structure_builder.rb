require "git"

module Pipefitter
  class StructureBuilder
    def initialize(repo:, branch:)
      @repo = repo
      @branch = branch
    end

    def run
      setup_branch
      merge_master_in

      if only_structure_conflict?
        create_new_structure
      end
    end

    def create_new_structure
      checkout_master_structure
      build
      stage
      create_new_branch
      commit
      push
    end

    def only_structure_conflict?
      git.diff.count == 1 && structure_conflict?
    end

    def structure_conflict?
      git.diff.any? { |file| file.path == structure_file }
    end

    def new_branch
      branch + "_pipefitter_structure"
    end

    private

    attr_reader :repo, :branch

    def git
      @git ||= Git.open(repo_path)
    end

    def setup_branch
      git.fetch
      git.reset_hard
      git.checkout(branch)
      git.pull("origin", branch)
    end

    def merge_master_in
      git.pull("origin", "master")
    end

    def checkout_master_structure
      git.checkout_file("master", structure_file)
    end

    def build
      Dir.chdir(repo_path) do
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

    def repo_path
      File.join("repos", repo)
    end
  end
end
