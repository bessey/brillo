require 'spec_helper'
require 'benchmark/ips'

RSpec.describe Brillo::Scrubber do
  let(:number) { "415-604-8790" }
  let(:email) { "mbessey@gmail.com" }
  let(:name) { "Mathern Smothers" }

  describe "name scrubber" do
    it "scrubs consistently across one run" do
      expect(Brillo::Scrubber::SCRUBBERS[:name].call(name)).to eq Brillo::Scrubber::SCRUBBERS[:name].call(name)
    end
  end

  describe "jumble scrubber" do
    it "scrubs consistently across one run" do
      expect(Brillo::Scrubber::SCRUBBERS[:jumble].call(name)).to eq Brillo::Scrubber::SCRUBBERS[:jumble].call(name)
    end
	end

	describe "faker scrubbers" do
	  it "scrubs with faker gem" do
	    expect {
        Brillo::Scrubber::SCRUBBERS[:faker_street_address].call(name)
        Brillo::Scrubber::SCRUBBERS[:faker_secondary_address].call(name)
        Brillo::Scrubber::SCRUBBERS[:faker_city].call(name)
        Brillo::Scrubber::SCRUBBERS[:faker_state].call(name)
        Brillo::Scrubber::SCRUBBERS[:faker_zip].call(name)
        Brillo::Scrubber::SCRUBBERS[:faker_name].call(name)
        Brillo::Scrubber::SCRUBBERS[:faker_first_name].call(name)
        Brillo::Scrubber::SCRUBBERS[:faker_last_name].call(name)
        Brillo::Scrubber::SCRUBBERS[:faker_phone_number].call(name)
			}.not_to raise_error

	  end
	end

  # describe "performance characteristics" do
  #   it "performs well" do
  #     Benchmark.ips do |x|
  #       x.report "phone" do
  #         Brillo::SCRUBBERS[:phone].call(number)
  #       end
  #       x.report "email" do
  #         Brillo::SCRUBBERS[:email].call(email)
  #       end
  #       Brillo::SCRUBBERS[:name].call(name)
  #       x.report "name" do
  #         Brillo::SCRUBBERS[:name].call(name)
  #       end
  #       x.report "jumble" do
  #         Brillo::SCRUBBERS[:jumble].call(name)
  #       end
  #       x.compare!
  #     end
  #   end
  # end
end
