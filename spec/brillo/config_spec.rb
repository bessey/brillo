# frozen_string_literal: true

require 'spec_helper'

RSpec.describe(Brillo::Config) do
  it 'converts obfuscation syntax to Polo compatible' do
    config = YAML.safe_load(<<-YAML)
    name: my_app
    explore:
    obfuscations:
      created_at:     default_time
      my_table.test:  name
    YAML
    config = Brillo::Config.new(config.deep_symbolize_keys)
    expect(config.obfuscations).to(eq(
      created_at: :default_time,
      'my_table.test' => :name
    ))
  end

  describe '#valid!' do
    it 'returns the config when there are no errors' do
      config = YAML.safe_load(<<-YAML)
      name: my_app
      explore:
      obfuscations:
        created_at:     default_time
        my_table.test:  name
      YAML
      config = Brillo::Config.new(config.deep_symbolize_keys)
      expect { config.verify! }.not_to(raise_error)
    end

    it 'catches invalid class errors' do
      config = YAML.safe_load(<<-YAML)
      name: my_app
      explore:
        i_dont_exist:
          tactic: all
      YAML
      config = Brillo::Config.new(config.deep_symbolize_keys)
      expect { config.verify! }.to(raise_error(Brillo::ConfigParseError))
    end

    it 'catches invalid obfuscation errors' do
      config = YAML.safe_load(<<-YAML)
      name: my_app
      explore:
      obfuscations:
        created_at:     i_dont_exist
      YAML
      config = Brillo::Config.new(config.deep_symbolize_keys)
      expect { config.verify! }.to(raise_error(Brillo::ConfigParseError))
    end
  end
end
