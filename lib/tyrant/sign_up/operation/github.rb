require 'uri'
require 'net/http'
require 'json'

module Tyrant

  class SignUp::GitHub < Trailblazer::Operation

    step Policy::Guard(:match_state!)
    step :check_client_id!
    step :check_client_secret!
    step :get_access_token!
    step :get_user_hash!
    step :model!

    def match_state!(options, params:, **)
      options["failure_message"] = "State has not been set" if !options["state"]
      return false if !options["state"]

      params[:state] == options["state"]
    end

    def check_client_id!(options, *)
      options["failure_message"] = "Client_id has not been set" if !options["client_id"]
      options["client_id"]
    end

    def check_client_secret!(options, *)
      options["failure_message"] = "Client_secret has not been set" if !options["client_secret"]
      options["client_secret"]
    end

    def get_access_token!(options, params:, **)
      options["url"] = 'https://github.com/login/oauth/access_token'
      options["args"] = []
      options["args"] << ["code", params[:code]] << ["client_id", options["client_id"]] << ["client_secret", options["client_secret"]]
      options["args"] << ["redirect_uri", options["redirect_uri"]] if !options["redirect_uri"]

      resp = Net::HTTP.get_response( get_uri!(options: options) )

      options["access_token_hash"] = {}
      resp.body.split('&').each do |element|
        array = element.split('=')
        options["access_token_hash"][array.first] = array.last
      end
    end

    def get_user_hash!(options, *)
      options["url"] = 'https://api.github.com/user'
      options["args"] = ["access_token", options["access_token_hash"]["access_token"]]

      resp = Net::HTTP.get_response( get_uri!(options: options) )

      options["user_hash"] = JSON::Parse(resp.body)
    end

    def model!(options, access_token_hash:, user_hash:, **)
      options["model"] = OpenStruct.new(user_hash)
    end

  private
    def get_uri!(options, *)
      uri = URI.parse(options["url"])
      new_query_ar = URI.decode_www_form(uri.query || '') << options["args"]
      uri.query = URI.encode_www_form(new_query_ar)

      return uri
    end

  end # class GitHub

end # module Tyrant::SignUp
