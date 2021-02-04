RSpec.describe BeRedisConfig do
  before { BeRedisConfig.instance.load_config(File.read('spec/fixtures/example.json')) }
  after { BeRedisConfig.instance.unload! }

  it "should load config" do
    expect(BeRedisConfig.instance.config_loaded?).to eq(true)
  end

  it "should have nodes" do
    expect( BeRedisConfig.instance.nodes.include?({ host: "127.0.0.1", port: 123 }) ).to eq(true)
    expect( BeRedisConfig.instance.nodes.include?({ host: "127.0.0.2", port: 234 }) ).to eq(true)
  end
end
