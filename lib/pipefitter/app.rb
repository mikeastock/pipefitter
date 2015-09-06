require "sinatra"
require "json"

require "pipefitter/structure_worker"

module Pipefitter
  class App < Sinatra::Base
    get "/" do
      "Hello World!"
    end

    post "/payload" do
      StructureWorker.perform_async(request.body.read)
    end
  end
end
