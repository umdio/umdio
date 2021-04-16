module Sinatra
    module UMDIO
      module Helpers
        require 'net/http'

        def wrapRequest url
          Net::HTTP.get(URI(url + "&t=0")).to_s
        end

        def wrapRequest_v1 url
          halt 502, "Bus Service Unavailible"
          #resp = Net::HTTP.get_response(URI(url + "&t=0"))
          #STDERR.puts resp

          #raise
          #resp.body.to_s
        end
      end
    end
end
