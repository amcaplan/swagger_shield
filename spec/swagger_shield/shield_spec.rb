require "spec_helper"

RSpec.describe SwaggerShield::Shield do
  subject { described_class.new(loaded_spec) }
  let(:loaded_spec) { YAML.load_file(swagger_file) }
  let(:swagger_file) { File.join(__dir__, '..', 'fixtures', 'swagger.yml') }

  describe 'validating body params' do
    let(:validation) { subject.validate('widgets', 'POST', params) }

    context 'Given a valid object is submitted' do
      let(:params) {{ name: 'foo', price: 19999 }}

      it 'does not return an error' do
        expect(validation).to eq([])
      end
    end

    context 'Given an object is submitted without required keys' do
      let(:params) {{}}

      it 'returns an Array of error(s)' do
        expect(validation).to eq([
          "The property '#/' did not contain a required property of 'name'",
          "The property '#/' did not contain a required property of 'price'"
        ])
      end
    end

    context 'Given an object is submitted with improperly typed keys' do
      let(:params) {{ name: 'foo', price: '19999' }}

      it 'returns an Array of error(s)' do
        expect(validation).to eq([
          "The property '#/price' of type String did not match the following type: integer"
        ])
      end
    end

    context 'Given an object is submitted with improperly formatted keys' do
      let(:params) {{ name: 'foo', price: 19999, created_at: 'not a date' }}

      it 'returns an Array of error(s)' do
        expect(validation).to eq([
          "The property '#/created_at' must be a valid RFC3339 date/time string"
        ])
      end
    end
  end

  end
end
