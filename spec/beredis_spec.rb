RSpec.describe BeRedis do
  it "has a version number" do
    expect(Beredis::VERSION).not_to be nil
  end

  context do
    subject { BeRedis.new }
    it "should not be in cluster mode by default" do
      expect(subject.cluster_mode?).to eq(false)
    end
  end
end
