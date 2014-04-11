require 'spec_helper'

describe EbisuConnection do
  it "version check" do
    expect(EbisuConnection::VERSION).to eq("0.0.8")
  end
end
