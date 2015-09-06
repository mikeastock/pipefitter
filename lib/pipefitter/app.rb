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
      pull_request = PullRequest.find(
        owner:  payload.fetch(:repository).fetch(:owner).fetch(:login),
        repo:   payload.fetch(:repository).fetch(:name),
        number: payload.fetch(:issue).fetch(:number),
      )
      StructureBuilder.run(branch: pull_request.branch)
    end
  end
end
