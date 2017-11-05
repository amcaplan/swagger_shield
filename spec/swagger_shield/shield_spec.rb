require "spec_helper"

RSpec.describe SwaggerShield::Shield do
  subject { described_class.new(loaded_spec) }
  let(:loaded_spec) { YAML.load_file(swagger_file) }
  let(:swagger_file) { File.join(__dir__, '..', 'fixtures', 'swagger.yml') }

  describe 'validating body params' do
    let(:validation) { subject.validate('/widgets', 'POST', params) }

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

    context 'Given an object is submitted with an Array with incorrect types' do
      let(:params) {{ name: 'foo', price: 19999, tags: ['a good tag', 123] }}

      it 'returns an Array of error(s)' do
        expect(validation).to eq([
          "The property '#/tags/1' of type Integer did not match the following type: string"
        ])
      end
    end

    context 'Given an object is submitted with an Object with incorrect types' do
      let(:params) {{ name: 'foo', price: 19999, metadata: { numericThing: 'not a number' } }}

      it 'returns an Array of error(s)' do
        expect(validation).to eq([
          "The property '#/metadata/numericThing' of type String did not match the following type: number"
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

  describe 'validating path params' do
    let(:validation) { subject.validate('/widgets/{id}', 'GET', params) }

    context 'Given valid params' do
      let(:params) {{ id: 1 }}

      it 'does not return an error' do
        expect(validation).to eq([])
      end
    end

    context 'Given an object is submitted without required keys' do
      let(:params) {{}}

      it 'returns an Array of error(s)' do
        expect(validation).to eq([
          "The property '#/' did not contain a required property of 'id'"
        ])
      end
    end

    context 'Given an object is submitted with improperly typed keys' do
      let(:params) {{ id: 'string not numeric' }}

      it 'returns an Array of error(s)' do
        expect(validation).to eq([
          "The property '#/id' of type String did not match the following type: integer"
        ])
      end
    end
  end

  describe 'validating path and body params together' do
    let(:validation) { subject.validate('/widgets/{id}', 'PUT', params) }

    context 'Given valid params' do
      let(:params) {{ id: 1, name: 'bar', price: 17999 }}

      it 'does not return an error' do
        expect(validation).to eq([])
      end
    end

    context 'Given an object is submitted without required keys' do
      let(:params) {{}}

      it 'returns an Array of error(s) from both sources' do
        expect(validation).to eq([
          "The property '#/' did not contain a required property of 'id'",
          "The property '#/' did not contain a required property of 'name'",
          "The property '#/' did not contain a required property of 'price'"
        ])
      end
    end

    context 'Given an object is submitted with improperly typed keys' do
      let(:params) {{ id: 'string not numeric', name: 12345, price: 'what is up here' }}

      it 'returns an Array of all error(s)' do
        expect(validation).to eq([
          "The property '#/id' of type String did not match the following type: integer",
          "The property '#/name' of type Integer did not match the following type: string",
          "The property '#/price' of type String did not match the following type: integer"
        ])
      end
    end
  end
end
