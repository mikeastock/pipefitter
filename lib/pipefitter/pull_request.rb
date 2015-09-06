require "github_api"

module Pipefitter
  class PullRequest
    def initialize(pull_request)
      @pull_request = pull_request
    end

    def self.find(owner:, repo:, number:)
      new(
        Pipefitter.github_client.pull_requests.find(owner, repo, number)
      )
    end

    def self.create(owner:, repo:, base:, head:, title:, body:)
      new(Pipefitter.
        github_client.
        pull_requests.
        create(
          owner,
          repo,
          base: base,
          head: head,
          title: title,
          body: body,
        ))
    end

    def branch
      pull_request.head.ref
    end

    def number
      pull_request.number
    end

    private

    attr_reader :pull_request
  end
end
