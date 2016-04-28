require 'rails_helper'
load 'Rakefile'

RSpec.describe Brillo::Dumper::MysqlDumper do
  let(:config) { Brillo::Config.new(Brillo.yaml_config) }
  subject { Brillo::Dumper::MysqlDumper }

  before do
    FileUtils.rm "tmp/dummy-scrubbed.dmp" if File.exists? "tmp/dummy-scrubbed.dmp"
    Brillo::Logger.logger = Logger.new(STDOUT)
  end

  it "returns true on successful dump" do
    dumper = subject.new(config)
    expect(dumper.dump[0]).to be true
    output = File.read("tmp/dummy-scrubbed.dmp")
    expect(output.length).not_to be_blank
  end

  it "raises a RuntimeError on unsuccessful dump" do
    config.db[:password] = "hfs6sd!@#%f467s7"
    dumper = subject.new(config)
    expect{dumper.dump[0]}.to raise_error(RuntimeError)
  end
end
