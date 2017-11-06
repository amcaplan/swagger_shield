module SwaggerShield
  class Shield
    include Enumerable

    def initialize(swagger_spec)
      @swagger_spec = swagger_spec.deep_dup
      @swagger_spec['buffer'] = {}
      load_route_definitions!
    end

    def validate(path, method, params)
      canonical_path_id = identify_path(path)

      errors = JSON::Validator.fully_validate(
        swagger_spec,
        params,
        fragment: "#/buffer/inputs/#{canonical_path_id}/#{method}"
      )
      errors.map { |error|
        error.match(/(?<message_part>.*) in schema/)[:message_part]
      }
    end

    def each
      return enum_for(__method__) unless block_given?

      paths.each do |path, info|
        yield path, info
      end
    end

    private
    attr_reader :swagger_spec

    def paths
      swagger_spec['buffer']['inputs'] ||= {}
    end

    def load_route_definitions!
      swagger_spec['paths'].each do |path, methods|
        path_id_regex = Regexp.new('\A' + path.gsub(/\{\w+\}/, "[^/]+") + '\z')
        path_info = {
          'original_path' => path,
          'regex' => path_id_regex,
        }

        methods.each do |method, method_info|
          required = []
          properties = {}

          each_param(method_info['parameters']) do |param|
            required << param['name'] if param['required']
            properties[param['name']] = param_schema_from(param)
          end

          path_info[method.upcase] = {
            'type' => 'object',
            'required' => required,
            'properties' => properties
          }
        end

        paths[path_id_regex.hash.to_s] = path_info
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

    def identify_path(path)
      swagger_spec['buffer']['inputs'].find { |_, info|
        info['regex'].match?(path)
      }.first
    end
  end
end
