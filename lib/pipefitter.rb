require "pipefitter/app"
require "pipefitter/pull_request"
require "pipefitter/structure_builder"

module Pipefitter
  def self.github_client
    @github_client ||= Github.new(basic_auth: ENV.fetch("GITHUB_TOKEN"))
  end
end
