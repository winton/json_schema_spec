##JsonSchemaHelper

Create and validate test parameters from JSON schema.

###Goals

* Generate webmock request/response parameters from JSON schema
* Easily change parameters for testing
* Rake helpers for client code to download JSON schema
* Easily validate parameters against schema

###Requirements

You are expected to be serving a `schema.json` file at the root of a URL that describes your resources.

####Example

    {
        "user.json": {
            "request": {
                "title": "GET user.json (request)",
                "type": "object",
                "additionalProperties": false,
                "properties": {
                    "id": {
                        "type": "integer"
                    },
                    "token": {
                        "type": "string"
                    }
                }
            },
            "response": {
                "title": "GET user.json (response)",
                "type": "object",
                "additionalProperties": false,
                "properties": {
                    "id": {
                        "type": "integer"
                    },
                    "avatar": {
                        "type": "string",
                        "optional": true
                    },
                    "name": {
                        "type": "string"
                    }
                }
            }
        }
    }

###Install

    gem install json_schema_helper

###Require

In your `spec_helper`:

    require "json_schema_helper"

In your `Rakefile` (only necessary within your client code):

    require "json_schema_helper/tasks"
    JsonSchemaHelper::Tasks.new("http://127.0.0.1:3000")

###Client code

####Download schema

Run this rake task to download your `schema.json` to `schema/fixtures`:

    rake spec:schema

####Test params from schema

    request, response = json_schema_params(:user, :get)

The `request` hash looks like this:

    { :id => 72238, :token => "token" }

The `response` hash looks like this:

    { :avatar => "avatar", :name => "name" }

**Integer** values are given a random number.

**String** values are given the same name as the key.

**Optional** parameters are not included.

####Modify test params

    request, response = json_schema_params(:user, :get, :request => { :id => 1 })

The `request` hash now looks like this:

    { :id => 1, :token => "token" }

####Webmock example

    request, response = json_schema_params(:user, :get)

    request  = params[:request]
    response = params[:response]

    stub_request(:get, "http://127.0.0.1:3000/user.json").
      with(:body => request).
      to_return(:body => response.to_json)

### Contribute

[Create an issue](https://github.com/winton/json_schema_helper/issues/new) to discuss template changes.

Pull requests for template changes and new branches are even better.

### Stay up to date

[Star this project](https://github.com/winton/json_schema_helper#) on Github.

[Follow Winton Welsh](http://twitter.com/intent/user?screen_name=wintonius) on Twitter.
