require "sinatra"
require "json"
require "active_support/hash_with_indifferent_access"

require "pipefitter/pull_request"

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
    end
  end
end
