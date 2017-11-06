require "swagger_shield/version"
require "json-schema"
require "swagger_shield/shield"
require "swagger_shield/before_action"

module SwaggerShield
  class << self
    def protect!(controller, swagger_file:, **opts)
      shield = SwaggerShield::Shield.new(
        YAML.load_file(swagger_file)
      )
      controller.before_action SwaggerShield::BeforeAction.new(shield), **opts
    end
  end
end
