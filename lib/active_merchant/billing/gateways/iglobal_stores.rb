module ActiveMerchant #:nodoc:
  module Billing #:nodoc:

    class IglobalStoresGateway < Gateway
      
      class_attribute :test_url, :live_url, :cart_url, :checkout_url

      self.cart_url = 'https://checkout.iglobalstores.com/iglobalstores/services/TempCartService'
      self.checkout_url = 'https://checkout.iglobalstores.com/'

      self.test_url = 'https://checkout.iglobalstores.com/iglobalstores/services/OrderRestService/v1.07'
      self.live_url = 'https://checkout.iglobalstores.com/iglobalstores/services/OrderRestService/v1.07'
      
      self.homepage_url = ''
      self.display_name = 'iGlobal Stores'
      self.supported_countries = ['US']
      self.default_currency = 'USD'
      
      
      # Creates a new IglobalStores Gateway
      #
      def initialize(options = {})
        options[:store_id]      ||= ENV['IGLOBAL_STORE_ID']
        options[:api_key]       ||= ENV['IGLOBAL_API_KEY']
        
        requires!(options, :store_id, :api_key)
        @options = options
        super
      end
      
      def build_cart(options = {})
        requires!(options, :reference_id)
        country = options.delete(:country)
        
        uri = URI.parse(self.cart_url)
        
        http              = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl      = true
        http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
        
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(stringify_params(options.merge(default_params)))
        
        response = begin
          verbose('Request', "#{uri.to_s}?#{request.body}")
          raw_response = http.request(request).body
          verbose('Response', raw_response)
          
          if raw_response == 'error'
            Response.new(false, "TempCartService: fail", {'Error' => raw_response}, :test => test?)
          else
            Response.new(true, "#{self.checkout_url}?tempCartUUID=#{raw_response}&country=#{country}", {}, :test => test?)
          end
        rescue Exception => e
          Response.new(false, "TempCartService: fail", {'Error' => "#{e.class.name}: #{e.message}"}, :test => test?)
        end


        return response
      end
      
      def get_order_numbers(options = {})
        requires!(options, :since_date)
        commit('orderNumbers', options)
      end
      
      def get_order_details(options = {})
        requires!(options, :order_id)
        commit('orderDetail', options)
      end
      
      def reference_id_lookup(options = {})
        requires!(options, :reference_id)
        commit('referenceIdLookup', options)
      end
      
      private

        def stringify_params(params)
          stringified = {}
          params.each_pair{|k,v| stringified[k.to_s.camelize(:lower)] = v}
          return stringified
        end

        def default_params
          {
            'store'     => options[:store_id],
            'secret'    => options[:api_key]
          }
        end
      
        #
        # commit logic
        #
        def commit(action, params = {}, url = (test? ? self.test_url : self.live_url))
          raw_response = response = nil
          success = false

          uri = URI.parse(url)
      
          response = begin
            http              = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl      = true
            http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
            
            request = Net::HTTP::Post.new(uri.request_uri)
            request.set_form_data(stringify_params(default_params.merge(params).merge('operation' => action)))
            
            verbose('Request', "#{uri.to_s}?#{request.body}")
            raw_response    = http.request(request)
            raw_response.body.force_encoding("ISO-8859-1").encode!("UTF-8") # force the proper character encoding
            verbose('Response', raw_response.body)
            
            hash = Hash.from_xml(raw_response.body)
            
            if error = hash['error']
              Response.new(false, error, hash || {}, :test => test?)
            else
              Response.new(true, "#{action}: success", hash || {}, :test => test?)
            end
          rescue Exception => e
            Response.new(false, "#{action}: fail", {'Error' => "#{e.class.name}: #{e.message}"}, :test => test?)
          end
        
          return response
        end
        
        def verbose(section, msg)
          return unless options[:verbose]
          puts "\n[iGlobalStores: #{section}]"
          puts msg
          puts "\n"
        end
      
    end
    
  end
  
end
