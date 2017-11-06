require "spec_helper"

RSpec.describe SwaggerShield::Shield, type: :request do
  subject { JSON.parse(response.body) }

  def required_error(fragment:, required:)
    {
      'status' => '422',
      'detail' => "The property '#{fragment}' did not contain a required property of '#{required}'",
      'source' => { 'pointer' => fragment }
    }
  end

  def type_error(fragment:, type:, actual_type:)
    {
      'status' => '422',
      'detail' => "The property '#{fragment}' of type #{actual_type} did not match the following type: #{type}",
      'source' => { 'pointer' => fragment }
    }
  end

  def multi_type_error(fragment:, actual_type:)
    {
      'status' => '422',
      'detail' => "The property '#{fragment}' of type #{actual_type} did not match one or more of the required schemas",
      'source' => { 'pointer' => fragment }
    }
  end

  describe 'validating a path with no substitutions' do
    describe 'and no params' do
      context 'Given there are no violations' do
        context 'Given no trailing slash' do
          it 'works normally' do
            get '/widgets'
            expect(response).to be_ok
            expect(subject.first).to include('name', 'price')
          end
        end

        context 'Given a trailing slash' do
          it 'works normally' do
            get '/widgets/'
            expect(response).to be_ok
            expect(subject.first).to include('name', 'price')
          end
        end
      end
    end

    describe 'with a request body' do
      before do
        headers = { "CONTENT_TYPE" => "application/json" }
        post '/widgets', params: { 'widget' => params }.to_json, headers: headers
      end

      context 'Given valid params' do
        let(:params) {{ name: 'Special Widget', price: 17888 }}

        it 'works normally' do
          expect(response).to be_created
          expect(subject).not_to have_key('errors')
        end
      end

      context 'Given required params are missing' do
        let(:params) {{}}

        it 'does not work normally' do
          expect(response).to have_http_status(422)
          expect(subject['errors']).to eq([
            required_error(fragment: '#/widget', required: 'name'),
            required_error(fragment: '#/widget', required: 'price')
          ])
        end
      end
    end
  end

  describe 'validating a path with substitutions' do
    describe 'and no request body' do
      context 'Given there are no violations' do
        it 'works normally' do
          get '/widgets/1'
          expect(response).to be_ok
          expect(subject).to include('name', 'price')
        end
      end

      context 'Given there are violations' do
        it 'does not work normally' do
          get '/widgets/hello'
          expect(response).to have_http_status(422)
          expect(subject['errors']).to eq([
            multi_type_error(fragment: '#/id', actual_type: 'String'),
          ])
        end
      end
    end

    describe 'and a request body' do
      before do
        headers = { "CONTENT_TYPE" => "application/json" }
        put "/widgets/#{id}", params: { 'widget' => params }.to_json, headers: headers
      end

      context 'Given there are violations' do
        context 'in the path' do
          let(:id) { 'hello' }
          let(:params) {{ 'name' => 'new name', 'price' => 11599 }}

          it 'does not work normally' do
            expect(response).to have_http_status(422)
            expect(subject['errors']).to eq([
              multi_type_error(fragment: '#/id', actual_type: 'String')
            ])
          end
        end

        context 'in the body' do
          let(:id) { 1 }
          let(:params) {{ 'name' => 'new name', 'price' => 'same old price' }}

          it 'does not work normally' do
            expect(response).to have_http_status(422)
            expect(subject['errors']).to eq([
              type_error(fragment: '#/widget/price', type: 'integer', actual_type: 'String')
            ])
          end
        end

        context 'in both' do
          let(:id) { 'hello' }
          let(:params) {{ 'name' => 'new name', 'price' => 'same old price' }}

          it 'does not work normally' do
            expect(response).to have_http_status(422)
            expect(subject['errors']).to eq([
              multi_type_error(fragment: '#/id', actual_type: 'String'),
              type_error(fragment: '#/widget/price', type: 'integer', actual_type: 'String')
            ])
          end
        end
      end
    end
  end
end
