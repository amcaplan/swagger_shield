module SwaggerShield
  class Shield
    def initialize(swagger_spec)
      @swagger_spec = swagger_spec.deep_dup
      load_route_definitions!
    end

    def validate(path, method, params)
      canonical_path_id = identify_path(path, paths[method])

      JSON::Validator.fully_validate(
        swagger_spec,
        params,
        fragment: "#/route_lookups/#{method}/#{canonical_path_id}/schema",
        errors_as_objects: true
      ).map { |error|
        {
          message: error[:message].match(/(?<message_part>.*) in schema/)[:message_part],
          fragment: error[:fragment]
        }
      }
    end

    private
    attr_reader :swagger_spec

    def paths
      swagger_spec['route_lookups'] ||= Hash.new do |h, k|
        h[k] = {}
      end
    end

    def load_route_definitions!
      base_path = swagger_spec.fetch('basePath', '')
      swagger_spec['paths'].each do |path, methods|
        path_id_regex = Regexp.new('\A' + base_path + path.gsub(/\{\w+\}/, "[^/]+") + '\z')
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

          paths[method.upcase][path_id_regex.hash.to_s] = {
            'regex' => path_id_regex,
            'schema' => {
              'type' => 'object',
              'required' => required,
              'properties' => properties
            }
          }
        end
      end
    end

    def each_param(params)
      (params || []).each do |param|
        if (schema = param['schema'])
          if (ref = schema['$ref'])
            schema = resolve_reference(ref)
          end
          schema['properties'].each do |name, definition|
            yield(
              'name' => name,
              'schema' => definition,
              'required' => schema['required'].include?(name)
            )
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
        baseline = param.except('name', 'in', 'required')
        return baseline unless param['in'] == 'path'
        case param['type']
        when 'integer'
          {
            'description' => baseline.delete('description'),
            'anyOf' => [
              baseline,
              {
                'type' => 'string',
                'pattern' => '\A\d+\z'
              }
            ]
          }
        else
          baseline
        end
      }
    end

    def identify_path(path, paths)
      paths.find { |_, info| info['regex'] =~ path }.first
    end
  end
end
