require "spec_helper"

RSpec.describe SwaggerShield::Shield do
  subject { described_class.new(loaded_spec) }
  let(:loaded_spec) { YAML.load_file(swagger_file) }
  let(:swagger_file) { File.join(__dir__, '..', 'fixtures', 'swagger.yml') }

  def required_error(path:, property:)
    {
      message: "The property '#{path}' did not contain a required property of '#{property}'",
      fragment: path
    }
  end

  def type_error(path:, type:, actual_type:)
    {
      message: "The property '#{path}' of type #{actual_type} did not match the following type: #{type}",
      fragment: path
    }
  end

  def multi_type_error(path:, actual_type:)
    {
      message: "The property '#{path}' of type #{actual_type} did not match one or more of the required schemas",
      fragment: path
    }
  end

  def format_error(path:, format:)
    {
      message: "The property '#{path}' must be a valid #{format} string",
      fragment: path
    }
  end

  describe 'validating body params' do
    let(:validation) { subject.validate('/widgets', 'POST', widget: params) }

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
          required_error(path: '#/widget', property: 'name'),
          required_error(path: '#/widget', property: 'price')
        ])
      end
    end

    context 'Given an object is submitted with improperly typed keys' do
      let(:params) {{ name: 'foo', price: '19999' }}

      it 'returns an Array of error(s)' do
        expect(validation).to eq([
          type_error(path: '#/widget/price', actual_type: 'string', type: 'integer')
        ])
      end
    end

    context 'Given an object is submitted with an Array with incorrect types' do
      let(:params) {{ name: 'foo', price: 19999, tags: ['a good tag', 123] }}

      it 'returns an Array of error(s)' do
        expect(validation).to eq([
          type_error(path: '#/widget/tags/1', actual_type: 'integer', type: 'string')
        ])
      end
    end

    context 'Given an object is submitted with an Object with incorrect types' do
      let(:params) {{ name: 'foo', price: 19999, metadata: { numericThing: 'not a number' } }}

      it 'returns an Array of error(s)' do
        expect(validation).to eq([
          type_error(path: '#/widget/metadata/numericThing', actual_type: 'string', type: 'number')
        ])
      end
    end

    context 'Given an object is submitted with improperly formatted keys' do
      let(:params) {{ name: 'foo', price: 19999, created_at: 'not a date' }}

      it 'returns an Array of error(s)' do
        expect(validation).to eq([
          format_error(path: '#/widget/created_at', format: 'RFC3339 date/time')
        ])
      end
    end
  end

  describe 'validating path params' do
    let(:validation) { subject.validate('/widgets/1', 'GET', params) }

    context 'Given valid params' do
      let(:params) {{ id: 1 }}

      it 'does not return an error' do
        expect(validation).to eq([])
      end
    end

    context 'Given an object is submitted with improperly typed keys' do
      let(:params) {{ id: 'string not numeric' }}

      it 'returns an Array of error(s)' do
        expect(validation).to eq([
          multi_type_error(path: '#/id', actual_type: 'string')
        ])
      end
    end
  end

  describe 'validating path and body params together' do
    let(:validation) { subject.validate('/widgets/{id}', 'PUT', id: id, widget: params) }

    context 'Given valid params' do
      let(:id) { 1 }
      let(:params) {{ name: 'bar', price: 17999 }}

      it 'does not return an error' do
        expect(validation).to eq([])
      end
    end

    context 'Given an object is submitted without required keys' do
      let(:id) { 1 }
      let(:params) {{}}

      it 'returns an Array of error(s) from both sources' do
        expect(validation).to eq([
          required_error(path: '#/widget', property: 'name'),
          required_error(path: '#/widget', property: 'price')
        ])
      end
    end

    context 'Given an object is submitted with improperly typed keys' do
      let(:id) { 'string not numeric' }
      let(:params) {{ name: 12345, price: 'what is up here' }}

      it 'returns an Array of all error(s)' do
        expect(validation).to eq([
          multi_type_error(path: '#/id', actual_type: 'string'),
          type_error(path: '#/widget/name', actual_type: 'integer', type: 'string'),
          type_error(path: '#/widget/price', actual_type: 'string', type: 'integer')
        ])
      end
    end
  end
end
