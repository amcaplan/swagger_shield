class ApplicationController < ActionController::API
  SwaggerShield.protect!(
    self,
    swagger_file: File.join('spec', 'fixtures', 'swagger.yml'),
    unless: -> { params[:skip_swagger_shield] }
  )
end
