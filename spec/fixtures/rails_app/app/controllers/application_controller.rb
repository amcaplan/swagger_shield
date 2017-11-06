class ApplicationController < ActionController::API
  before_action :shield!

  def shield!
    swagger_shield.validate(request.path, request.method, params)
  end

  def swagger_shield
    @swagger_shield ||= SwaggerShield::Shield.new(
      YAML.load_file(File.join 'spec', 'fixtures', 'swagger.yml')
    )
  end
end
