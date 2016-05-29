require 'rails_helper'
load 'Rakefile'

RSpec.describe "rake db:scrub" do
  let(:account1) { Account.create!(name: "Matthew Bessey", email: "mbessey@gmail.com", phone: "555-413-5234") }
  let(:account2) { Account.create!(name: "Matthew Bessey", email: "mbessey@caring.com", phone: "555-413-5234") }
  let(:obfuscated_phone_number) { (555_000_0000 + account1.id).to_s }
  before do
    Account.delete_all
    account1
    account2
  end
  it "obfuscates as specified in brillo.yml" do
    Brillo.scrub! logger: Logger.new(STDOUT)
    `gunzip -f #{Rails.root.join "tmp/dummy-scrubbed.dmp.gz"}`
    output = File.read("tmp/dummy-scrubbed.dmp")
    expect(output).to include "mbessey@caring.com"
    expect(output).not_to include "mbessey@gmail.com"
    expect(output).not_to include "Matthew Bessey"
    expect(output).not_to include "555-413-5234"
    expect(output).to include obfuscated_phone_number
  end

  it "loads a scrub" do
    Brillo.scrub! logger: Logger.new(STDOUT)
    Account.delete_all
    Brillo.load! logger: Logger.new(STDOUT)
    expect(Account.count).to eq 2
    expect(Account.where(name: "Matthew Bessey").count).to eq 0
  end
end
