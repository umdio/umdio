module Sinatra
  module UMDIO
    module Helpers
      def bad_url_error(message, docs)
        message ||= "Check your url! It doesn't seem to correspond to anything on the umd.io api. If you think it should, create an issue on our github page."
        docs ||= 'https://docs.umd.io'
        {
          error_code: 400,
          message: message,
          docs: docs
        }.to_json
      end

      def not_found_error(message, docs)
        message ||= "Check your url! It doesn't seem to correspond to anything on the umd.io api. If you think it should, create an issue on our github page."
        docs ||= 'https://docs.umd.io'
        {
          error_code: 404,
          message: message,
          docs: docs
        }.to_json
      end

      def service_unavailable_error(message, docs)
        message ||= 'The path you requested is not currently available. Please try again later'
        docs ||= 'https://docs.umd.io'
        {
          error_code: 502,
          message: message,
          docs: docs
        }.to_json
      end
    end
  end
end
