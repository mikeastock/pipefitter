RSpec.describe Pipefitter::StructureWorker do
  describe "#perform" do
    let(:owner) { "mikeastock" }
    let(:repo) { "sample_app" }
    let(:number) { 1 }
    let(:payload) do
      {
        repository: {
          name: repo,
          owner: {
            login: owner
          }
        },
        issue: {
          number: number
        }
      }
    end

    it "find's the base pull request" do
      allow(Pipefitter::StructureBuilder).to receive(:new) { spy }
      allow(Pipefitter::PullRequest).to receive(:create) { spy }

      expect(Pipefitter::PullRequest).to receive(:find).with(
        owner: owner,
        repo: repo,
        number: number
      ) { spy }

      Pipefitter::StructureWorker.new.perform(payload)
    end

    it "instantiate's Pipefitter::StructureBuilder" do
      branch = "test_branch"
      base_pull_request = spy(branch: branch)

      allow(Pipefitter::PullRequest).to receive(:find) { base_pull_request }
      allow(Pipefitter::PullRequest).to receive(:create) { spy }

      expect(Pipefitter::StructureBuilder).to receive(:new).with(
        repo: repo,
        branch: base_pull_request.branch
      ) { spy }

      Pipefitter::StructureWorker.new.perform(payload)
    end

    it "calls Pipefitter::StructureBuilder#run" do
      builder = spy

      allow(Pipefitter::PullRequest).to receive(:find) { spy }
      allow(Pipefitter::PullRequest).to receive(:create) { spy }
      allow(Pipefitter::StructureBuilder).to receive(:new) { builder }

      Pipefitter::StructureWorker.new.perform(payload)
      expect(builder).to have_received(:run)
    end

    context "structure changed" do
      it "creates a new pull request" do
        branch = "test_branch"
        base_pull_request = spy(branch: branch, number: number)
        new_branch = branch + "_new"
        builder = spy(new_branch: new_branch)

        allow(Pipefitter::PullRequest).to receive(:find) { base_pull_request }
        allow(Pipefitter::StructureBuilder).to receive(:new) { builder }

        expect(Pipefitter::PullRequest).to receive(:create).with(
          owner: owner,
          repo:  repo,
          base:  branch,
          head:  new_branch,
          title: "Pipefitter structure update for #{branch}",
          body:  "Updates PR ##{number}",
        )

        Pipefitter::StructureWorker.new.perform(payload)
      end
    end
  end
end
