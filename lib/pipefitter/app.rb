require "sinatra"
require "json"
require "active_support/hash_with_indifferent_access"

require "pipefitter/pull_request"
require "pipefitter/structure_builder"

module Pipefitter
  class App < Sinatra::Base
    get "/" do
      "Hello World!"
    end

    post "/payload" do
      payload = JSON.parse(request.body.read, object_class: HashWithIndifferentAccess)
      base_pull_request = PullRequest.find(
        owner:  payload.fetch(:repository).fetch(:owner).fetch(:login),
        repo:   payload.fetch(:repository).fetch(:name),
        number: payload.fetch(:issue).fetch(:number),
      )
      builder = StructureBuilder.new(branch: base_pull_request.branch)
      builder.run

      PullRequest.create(
        base: base_pull_request.branch,
        head: builder.new_branch,
        title: "Pipefitter structure update for #{base_pull_request.branch}",
        body: "Updates PR ##{pull_request.number}",
      )
    end
  end
end
