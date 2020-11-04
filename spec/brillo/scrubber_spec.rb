# frozen_string_literal: true

require 'spec_helper'
require 'benchmark/ips'

RSpec.describe(Brillo::Scrubber) do
  let(:number) { '415-604-8790' }
  let(:email) { 'mbessey@gmail.com' }
  let(:name) { 'Mathern Smothers' }

  describe 'name scrubber' do
    it 'scrubs consistently across one run' do
      expect(Brillo::Scrubber::SCRUBBERS[:name].call(name)).to(eq(Brillo::Scrubber::SCRUBBERS[:name].call(name)))
    end
  end

  describe 'jumble scrubber' do
    it 'scrubs consistently across one run' do
      expect(Brillo::Scrubber::SCRUBBERS[:jumble].call(name)).to(eq(Brillo::Scrubber::SCRUBBERS[:jumble].call(name)))
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
