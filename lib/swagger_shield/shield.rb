module SwaggerShield
  class Shield
    def initialize(swagger_spec)
      @swagger_spec = swagger_spec.deep_dup
      @swagger_spec['buffer'] = {}
      load_route_definitions!
    end

    def validate(path, method, params)
      subbed_path = path.gsub('/', '\\')
      errors = JSON::Validator.fully_validate(
        swagger_spec,
        params,
        fragment: "#/buffer/inputs/#{subbed_path}/#{method}"
      )
      errors.map { |error|
        error.match(/(?<message_part>.*) in schema/)[:message_part]
      }
    end

    private
    attr_reader :swagger_spec

    def paths
      swagger_spec['buffer']['inputs'] ||= Hash.new do |hash, key|
        hash[key] = {}
      end
    end

    def load_route_definitions!
      swagger_spec['paths'].each do |path, methods|
        methods.each do |method, info|
          required = []
          properties = {}

          each_param(info['parameters']) do |param|
            required << param['name'] if param['required']
            properties[param['name']] = param_schema_from(param)
          end

          json_schema_path = path.gsub('/','\\')

          paths[json_schema_path][method.upcase] = {
            'type' => 'object',
            'required' => required,
            'properties' => properties
          }
        end
      end
    end

    def each_param(params)
      (params || []).each do |param|
        if (schema = param['schema'])
          if (ref = schema['$ref'])
            schema = resolve_reference(ref)
            schema['properties'].each do |name, definition|
              yield(
                'name' => name,
                'schema' => definition,
                'required' => schema['required'].include?(name)
              )
            end
          else
            schema.each do |schema_param|
              yield schema_param
            end
          end
        else
          yield param
        end
      end
    end

    def resolve_reference(ref)
      ref.match(/#\/(?<path>.*)/)[:path].split('/').inject(swagger_spec) do |resolved, branch|
        resolved[branch]
      end
    end

    def param_schema_from(param)
      param.fetch('schema') {
        param.except('name', 'in', 'required')
      }
    end
  end
end
