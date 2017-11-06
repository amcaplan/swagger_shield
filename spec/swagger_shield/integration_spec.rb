require "spec_helper"

RSpec.describe SwaggerShield::Shield, type: :request do
  subject { JSON.parse(response.body) }

  describe 'validating a path with no substitutions' do
    context 'Given there are no violations' do
      context 'Given no trailing slash' do
        it 'works normally' do
          get '/widgets'
          expect(response).to be_ok
          expect(subject.first).to include('name', 'price')
        end
      end

      context 'Given a trailing slash' do
        it 'does the normal thing' do
          get '/widgets/'
          expect(response).to be_ok
          expect(subject.first).to include('name', 'price')
        end
      end
    end
  end
end
