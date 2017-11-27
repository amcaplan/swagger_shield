# SwaggerShield

Tired of getting weird errors when users (or your own clients) submit random
junk to your Rails API?  `SwaggerShield` is here to save the day!

## Usage

```ruby
# You can add to any controller, or to ApplicationController if you want
# SwaggerShield to protect your whole app.
class ApplicationController < ActionController::API
  SwaggerShield.protect!(
    self,

    # replace with the location of your actual swagger YAML file:
    swagger_file: File.join('config', 'swagger.yml'),

    # add on any valid "if" or "unless" conditionals that can be applied to a
    # Rails before_action
    if: -> { current_user.test_user? },
    unless: -> { params[:skip_swagger_shield] }
  )
end
```

Now, everything will work as before, as long as the requests are properly
formatted.  But if requests don't match your Swagger spec:

![You Shall Not Pass!](https://i0.wp.com/gifrific.com/wp-content/uploads/2017/11/you-shall-not-pass-gandalf-lotr.gif)

OK, maybe it's not that dramatic.  But your client will see an error pointing to
exactly what they messed up in the request:

```json
{
  "errors": [
    {
      "status": "422",
      "detail": "The property '#/widget/price' of type string did not match the following type: integer",
      "source": {
        "pointer": "#/widget/price"
      }
    }
  ]
}
```

(Only errors in JSON API format are supported, hopefully that'll be updated
soon...)

## Warning!

This project is under active development, being built up in stages as bits
become necessary for projects that make money.  So there's still plenty of stuff
to implement; use at your own risk.

That said, the project will gratefully accept the implementation of new types,
better error messaging, etc., basically anything you find useful in your own
work which seems generally applicable.  So please [contribute](#development)!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'swagger_shield'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install swagger_shield

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amcaplan/swagger_shield. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SwaggerShield project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/amcaplan/swagger_shield/blob/master/CODE_OF_CONDUCT.md).
