require 'spec_helper'

RSpec.describe Brillo::Config do
  it "converts obfuscation syntax to Polo compatible" do
    config = YAML.load <<-YAML
    name: my_app
    explore:
    obfuscations:
      created_at:     default_time
      my_table.test:  name
    YAML
    config = Brillo::Config.new(config)
    expect(config.obfuscations).to eq(
      created_at: :default_time,
      "my_table.test" => :name
    )
  end
end
