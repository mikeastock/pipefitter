require "rack/test"

RSpec.describe Pipefitter::App do
  include Rack::Test::Methods

  def app
    Pipefitter::App
  end

  describe "GET /" do
    it "says hello" do
      get "/"
      expect(last_response).to be_ok
    end
  end

  describe "POST /payload" do
    it "process's a Github webhook payload" do
      expect(Pipefitter::StructureWorker).to receive(:perform_async)

      post "/payload"
    end
  end
end
