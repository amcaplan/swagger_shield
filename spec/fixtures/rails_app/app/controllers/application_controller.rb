class ApplicationController < ActionController::API
  before_action :shield!

  def shield!
    errors = swagger_shield.validate(
      request.path,
      request.method,
      params.to_unsafe_h
    )

    unless errors.empty?
      formatted = errors.map { |error|
        {
          status: '422',
          detail: error[:message],
          source: { pointer: error[:fragment] }
        }
      }
      render json: { errors: formatted }, status: :unprocessable_entity
    end
  end

  def swagger_shield
    @swagger_shield ||= SwaggerShield::Shield.new(
      YAML.load_file(File.join 'spec', 'fixtures', 'swagger.yml')
    )
  end
end
