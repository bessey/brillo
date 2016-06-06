require 'rails_helper'
load 'Rakefile'

RSpec.describe "brillo.rake" do
  let(:account1) { Account.create!(name: "Matthew Bessey", email: "mbessey@gmail.com", phone: "555-413-5234") }
  let(:account2) { Account.create!(name: "Matthew Bessey", email: "mbessey@caring.com", phone: "555-413-5234") }
  let(:obfuscated_phone_number) { (555_000_0000 + account1.id).to_s }
  before do
    Account.delete_all
    account1
    account2
  end
  describe "rake db:scrub" do
    it "obfuscates as specified in brillo.yml" do
      `rake db:scrub`
      `gunzip -f #{Rails.root.join "tmp/dummy-scrubbed.dmp.gz"}`
      output = File.read("tmp/dummy-scrubbed.dmp")
      expect(output).to include "mbessey@caring.com"
      expect(output).not_to include "mbessey@gmail.com"
      expect(output).not_to include "Matthew Bessey"
      expect(output).not_to include "555-413-5234"
      expect(output).to include obfuscated_phone_number
    end
  end

  describe "rake db:load" do
    it "loads a scrub" do
      `rake db:scrub`
      Account.delete_all
      `rake db:load`
      expect(Account.count).to eq 2
      expect(Account.where(name: "Matthew Bessey").count).to eq 0
    end
  end
end
