require 'spec_helper'

RSpec.describe Brillo do
  it "converts obfuscation syntax to Polo compatible" do
    config = YAML.load <<-YAML
    name: my_app
    explore:
    obfuscations:
      created_at:     default_time
      my_table.test:  name
    YAML
    brillo = Brillo.new(config)
    expect(brillo.obfuscations).to eq(
      created_at: Brillo::SCRUBBERS[:default_time],
      "my_table.test" => Brillo::SCRUBBERS[:name]
    )
  end
end
