require 'rails_helper'
load 'Rakefile'

RSpec.describe "rake db:scrub" do
  before do
    Account.delete_all
    Account.create!(name: "Matthew Bessey", email: "mbessey@gmail.com", phone: "555-413-5234")
    Account.create!(name: "Matthew Bessey", email: "mbessey@caring.com", phone: "555-413-5234")
  end
  it "obfuscates as specified in brillo.yml" do
    Rake::Task["db:scrub"].invoke
    output = File.read("tmp/dummy-scrubbed.dmp")
    expect(output).to include "mbessey@caring.com"
    expect(output).not_to include "mbessey@gmail.com"
    expect(output).not_to include "Matthew Bessey"
    expect(output).not_to include "555-413-5234"
  end

  it "loads a scrub", :focus do
    Rake::Task["db:scrub"].invoke
    Account.delete_all
    Rake::Task["db:load"].invoke
    expect(Account.count).to eq 2
    expect(Account.where(name: "Matthew Bessey").count).to eq 0
  end
end
