require "swagger_shield/version"
require "json-schema"
require "swagger_shield/shield"

module SwaggerShield
  class << self
    def protect!(controller, swagger_file:)
      swagger_shield = SwaggerShield::Shield.new(
        YAML.load_file(swagger_file)
      )

      controller.before_action do
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
    end
  end
end
