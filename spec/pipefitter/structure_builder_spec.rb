RSpec.describe Pipefitter::StructureBuilder do
  let(:branch) { "fake_branch" }
  let(:builder) { Pipefitter::StructureBuilder.new(branch: branch) }

  describe "#run" do
    let(:git) { spy }

    before do
      allow(Git).to receive(:open) { git }
      allow(builder).to receive(:build)
    end

    it "fetches the branch" do
      builder.run
      expect(git).to have_received(:fetch)
    end

    it "resets the repo" do
      builder.run
      expect(git).to have_received(:reset_hard)
    end

    it "checkouts the branch" do
      builder.run
      expect(git).to have_received(:checkout).with(branch)
    end

    it "pulls the branch" do
      builder.run
      expect(git).to have_received(:pull).with("origin", branch)
    end

    it "checkouts master's structure" do
      builder.run
      expect(git).to have_received(:checkout_file).with("master", "db/structure.sql")
    end

    it "stages db/structure.sql" do
      builder.run
      expect(git).to have_received(:add).with("db/structure.sql")
    end

    context "changed" do
      let(:new_branch) { branch + "_pipefitter_structure" }

      before do
        allow(builder).to receive(:changed?) { true }
      end

      it "creates a new branch" do
        builder.run
        expect(git).to have_received(:branch).with(new_branch)
      end

      it "commits" do
        builder.run
        expect(git).to have_received(:commit).with(/Pipefitter updated structure at/)
      end

      it "pushes" do
        builder.run
        expect(git).to have_received(:push).with("origin", new_branch)
      end
    end
  end

  describe "#changed?" do
    context "changed" do
      it "checks if db/structure.sql has changed" do
        diff = [double(path: "db/structure.sql")]
        git = double(diff: diff)
        allow(Git).to receive(:open) { git }

        expect(builder.changed?).to be true
      end
    end

    context "not changed" do
      it "checks if db/structure.sql has changed" do
        diff = [double(path: "fake_file_we_do_not_care_about")]
        git = double(diff: diff)
        allow(Git).to receive(:open) { git }

        expect(builder.changed?).to be false
      end
    end
  end
end
