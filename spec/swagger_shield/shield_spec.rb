require "spec_helper"

RSpec.describe SwaggerShield::Shield do
  subject { described_class.new(loaded_spec) }
  let(:loaded_spec) { YAML.load_file(swagger_file) }
  let(:swagger_file) { File.join(__dir__, '..', 'fixtures', 'swagger.yml') }

  it "does not return an error when a valid object is submitted" do
    expect(subject.validate('widgets', 'POST', { name: 'foo', price: 19999 }))
      .to eq([])
  end

  it "returns an error when objects are submitted without required keys" do
    expect(subject.validate('widgets', 'POST', {}))
      .to eq([
        "The property '#/' did not contain a required property of 'name'",
        "The property '#/' did not contain a required property of 'price'"
      ])
  end

  it "returns an error when objects are submitted with improperly typed keys" do
    expect(subject.validate('widgets', 'POST', { name: 'foo', price: '19999' }))
      .to eq(["The property '#/price' of type String did not match the following type: integer"])
  end

  it "returns an error when objects are submitted with improperly formatted keys" do
    expect(subject.validate('widgets', 'POST', { name: 'foo', price: 19999, created_at: 'not a date' }))
      .to eq(["The property '#/created_at' must be a valid RFC3339 date/time string"])
  end
end
