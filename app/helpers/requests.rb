module Sinatra
  module UMDIO
    module Helpers
      require 'net/http'

      def wrapRequest(url)
        Net::HTTP.get(URI(url + '&t=0')).to_s
      end

      def wrapRequest_v1(url)
        Net::HTTP.get(URI(url + '&t=0')).to_s
        halt 502, 'Bus Service Unavailible'
      end
    end
  end
end
