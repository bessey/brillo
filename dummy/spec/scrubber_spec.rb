require 'rails_helper'
load 'Rakefile'

RSpec.describe "rake db:scrub" do
  it "obfuscates as specified in brillo.yml" do
    Account.create!(name: "Matthew Bessey", email: "mbessey@gmail.com", phone: "555-413-5234")
    Account.create!(name: "Matthew Bessey", email: "mbessey@caring.com", phone: "555-413-5234")
    Rake::Task["db:scrub"].invoke
    output = File.read("tmp/dummy-scrubbed.dmp.gz")
    expect(output).to include "mbessey@caring.com"
    expect(output).not_to include "mbessey@gmail.com"
    expect(output).not_to include "Matthew Bessey"
    expect(output).not_to include "555-413-5234"
  end
end
