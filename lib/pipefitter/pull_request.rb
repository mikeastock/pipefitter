require "github_api"

module Pipefitter
  class PullRequest
    def initialize(pull_request)
      @pull_request = pull_request
    end

    def self.find(owner:, repo:, number:)
      github = Github.new(basic_auth: ENV.fetch("GITHUB_TOKEN"))
      new(
        github.pull_requests.find(owner, repo, number)
      )
    end

    def branch
      pull_request.head.ref
    end

    private

    attr_reader :pull_request
  end
end
