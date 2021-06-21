module Sinatra
  module UMDIO
    module Helpers
      require 'net/http'

      def wrapRequest(url)
        Net::HTTP.get(URI(url + '&t=0')).to_s
      end
    end
  end
end
