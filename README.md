##JsonSchemaSpec

Generate fixtures from JSON schemas

###Goals

* Generate webmock requests and responses from JSON schema
* Easily alter parameters for testing
* Automatically validate altered parameters against schema
* Rake helpers for client code to download JSON schema

###Requirements

You serve a `schema.json` file at the root of a URL that describes your resources.

####Example schema.json

    {
        "user.json": {
            "get": {
                "request": {
                    "title": "GET user.json (request)",
                    "type": "object",
                    "additionalProperties": false,
                    "properties": {
                        "id":    { "type": "integer" },
                        "token": { "type": "string" }
                    }
                },
                "response": {
                    "title": "GET user.json (response)",
                    "type": "object",
                    "additionalProperties": false,
                    "properties": {
                        "id":     { "type": "integer" },
                        "avatar": { "type": "string", "optional": true },
                        "name":   { "type": "string" }
                    }
                }
            }
        }
    }

###Install

    gem install json_schema_spec

###Require

In your `spec_helper`:

    require "json_schema_spec"

###Client side project setup

In your `Rakefile`:

    require "json_schema_spec/tasks"
    JsonSchemaSpec::Tasks.new("http://127.0.0.1:3000")

####Download schema

Download `schema.json` from the URL specified in your `Rakefile`:

    rake spec:schema

The schema lives in `schema/fixtures`.

###Server side project setup

On Rails, your schema is automatically detected at `/schema.json`.

If your `schema.json` is somewhere else, try this:

    JsonSchemaSpec.schema = get("/users/schema.json")

###Generate test parameters

    request, response = json_schema_params(:user, :get)

The `request` hash looks like this:

    { :id => 72238, :token => "token" }

The `response` hash looks like this:

    { :avatar => "avatar", :name => "name" }

**Integer** values are given a random number.

**String** values are given the same name as the key.

**Optional** parameters are not included.

###Modify test parameters

    request, response = json_schema_params(:user, :get, :request => { :id => 1 })

The `request` hash now looks like this:

    { :id => 1, :token => "token" }

Modified parameters are validated against your schema using [json-schema](https://github.com/hoxworth/json-schema).

###Webmock example

    request, response = json_schema_params(:user, :get)

    request  = params[:request]
    response = params[:response]

    stub_request(:get, "http://127.0.0.1:3000/user.json").
      with(:body => request).
      to_return(:body => response.to_json)

### Contribute

[Create an issue](https://github.com/winton/json_schema_spec/issues/new) to discuss template changes.

Pull requests for template changes and new branches are even better.

### Stay up to date

[Star this project](https://github.com/winton/json_schema_spec#) on Github.

[Follow Winton Welsh](http://twitter.com/intent/user?screen_name=wintonius) on Twitter.
