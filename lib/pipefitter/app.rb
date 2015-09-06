require "sinatra"
require "json"

require "pipefitter/structure_worker"

module Pipefitter
  class App < Sinatra::Base
    get "/" do
      "Hello World!"
    end

    post "/payload" do
      payload = JSON.parse(request.body.read)
      StructureWorker.perform_async(payload)
    end
  end
end
