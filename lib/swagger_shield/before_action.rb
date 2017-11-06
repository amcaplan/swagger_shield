module SwaggerShield
  class BeforeAction
    def initialize(shield)
      @shield = shield
    end

    def before(controller)
      request = controller.request
      params = controller.params

      errors = shield.validate(
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
        controller.render json: { errors: formatted }, status: :unprocessable_entity
      end
    end

    private
    attr_reader :shield
  end
end
