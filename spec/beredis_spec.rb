RSpec.describe BeRedis do
  it "has a version number" do
    expect(Beredis::VERSION).not_to be nil
  end

  context do
    subject { BeRedis.new }

    it "should return Redis object" do
      expect(subject.class).to eq(Redis)
    end
  end
end
