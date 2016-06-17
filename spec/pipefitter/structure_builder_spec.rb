RSpec.describe Pipefitter::StructureBuilder do
  let(:branch) { "fake_branch" }
  let(:builder) { Pipefitter::StructureBuilder.new(repo: "procore", branch: branch) }

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

    it "merges in master" do
      builder.run
      expect(git).to have_received(:pull).with("origin", "master")
    end
  end

  describe "#create_new_structure" do
    let(:git) { spy }

    before do
      allow(Git).to receive(:open) { git }
      allow(builder).to receive(:build)
    end

    it "checkouts master's structure" do
      builder.create_new_structure
      expect(git).to have_received(:checkout_file).with("master", "db/structure.sql")
    end

    it "stages db/structure.sql" do
      builder.create_new_structure
      expect(git).to have_received(:add).with("db/structure.sql")
    end

    it "creates a new branch" do
      builder.create_new_structure
      expect(git).to have_received(:branch).with(builder.new_branch)
    end

    it "commits" do
      builder.create_new_structure
      expect(git).to have_received(:commit).with(/Pipefitter updated structure at/)
    end

    it "pushes" do
      builder.create_new_structure
      expect(git).to have_received(:push).with("origin", builder.new_branch)
    end
  end

  describe "#only_structure_conflict?" do
    it "checks if there is one conflict that is structure file" do
      diff = [double(path: "db/structure.sql")]
      git = double(diff: diff)
      allow(Git).to receive(:open) { git }

      expect(builder.structure_conflict?).to be true
    end
  end

  describe "#structure_conflict?" do
    context "conflict" do
      it "checks if db/structure.sql has changed" do
        diff = [double(path: "db/structure.sql"), double(path: "app/models/user.rb")]
        git = double(diff: diff)
        allow(Git).to receive(:open) { git }

        expect(builder.structure_conflict?).to be true
      end
    end

    context "no conflict" do
      it "checks if db/structure.sql has changed" do
        diff = [double(path: "fake_file_we_do_not_care_about")]
        git = double(diff: diff)
        allow(Git).to receive(:open) { git }

        expect(builder.structure_conflict?).to be false
      end
    end
  end

  describe "#new_branch" do
    it "appends _pipefitter_structure" do
      expect(builder.new_branch).to eq(branch + "_pipefitter_structure")
    end
  end
end
