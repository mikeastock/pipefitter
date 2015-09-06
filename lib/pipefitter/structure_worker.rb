require "sidekiq"
require "json"
require "active_support/hash_with_indifferent_access"

require "pipefitter/pull_request"
require "pipefitter/structure_builder"

module Pipefitter
  class StructureWorker
    include Sidekiq::Worker

    def perform(unparsed)
      payload = JSON.parse(unparsed, object_class: HashWithIndifferentAccess)
      owner = payload.fetch(:repository).fetch(:owner).fetch(:login)
      repo = payload.fetch(:repository).fetch(:name)

      base_pull_request = PullRequest.find(
        owner:  owner,
        repo:   repo,
        number: payload.fetch(:issue).fetch(:number),
      )

      builder = StructureBuilder.new(
        repo: repo,
        branch: base_pull_request.branch,
      )
      builder.run

      PullRequest.create(
        owner:  owner,
        repo:   repo,
        base: base_pull_request.branch,
        head: builder.new_branch,
        title: "Pipefitter structure update for #{base_pull_request.branch}",
        body: "Updates PR ##{base_pull_request.number}",
      )
    end
  end
end
