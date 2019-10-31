module Sinatra
    module UMDIO
      module Helpers
        require 'net/http'

        def wrapRequest url
          Net::HTTP.get_response(URI(url)).to_s
        end
      end
    end
end