require "net/http"

module V0
  class ComponentGenerator < Rails::Generators::NamedBase
    argument :description, type: :string, default: ""
    @api_url = "https://api.v0.dev"
    @token = ENV["V0_API_TOKEN"]


    def fetch_from_v0
      url = URI(@api_url + "/chat")

      http = Net.http.new(url.hot, url.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(url)
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@token}"

      data = {
        "message": :description
      }

      request["body"] = data.to_json

      response = http.request(request)
      output = JSON.parse(response.body)
      return output if response.code == "200"
      nil
    end
  end
end
