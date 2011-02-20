require 'ipaddr'

# Copyright (c) 2008 Peter Boling
# Portions Copyright (c) 2005 Jamis Buck
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
module ExceptionNotifiable

  #For reference these are the error codes that Exception Notifier can inherently handle.
  #Official w3.org HTTP 1.1 Error Codes:
  #http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
  #
  #400 Bad Request
      #The request could not be understood by the server due to malformed syntax. 
      #The client SHOULD NOT repeat the request without modifications.
  #403 Forbidden
      #The server understood the request, but is refusing to fulfill it
  #404 Not Found
      #The server has not found anything matching the Request-URI
  #405 Method Not Allowed
      #The method specified in the Request-Line is not allowed for the resource identified by the Request-URI
      #This is not implemented entirely as the response is supposed to contain a list of accepted methods.
  #410 Gone
      #The requested resource is no longer available at the server and no forwarding address is known. This condition is expected to be considered permanent
  #500 Internal Server Error
      #The server encountered an unexpected condition which prevented it from fulfilling the request.
  #501 Not Implemented
      #The server does not support the functionality required to fulfill the request.
  #503 Service Unavailable
      #The server is currently unable to handle the request due to a temporary overloading or maintenance of the server.
  def self.included(target)
    target.extend(ClassMethods)
    #lifted from http://ruby.jamisbuck.org/rails-injected.html
    super
    # Add the following class attributes to the classes that include ExceptionNotifiable
    #  HTTP status codes and what their 'English' status message is
    #  Rails error classes to rescue and how to rescue them
    #  error_layout:
    #     can be defined at controller level to the name of the layout, 
    #     or set to true to render the controller's own default layout, 
    #     or set to false to render errors with no layout
    target.class_eval <<-EOF, __FILE__, __LINE__+1
      def self.error_layout=(layout = true)
        @@error_layout = layout
      end
      def self.error_layout
        @@error_layout
      end
      def self.http_error_codes=(codes = { "400" => "Bad Request", "403" => "Forbidden", "404" => "Not Found",
                                            "405" => "Method Not Allowed", "410" => "Gone", "500" => "Internal Server Error",
                                            "501" => "Not Implemented", "503" => "Service Unavailable" })
          @@http_error_codes = codes
      end
      def self.http_error_codes
        @@http_error_codes
      end
      def self.rails_error_classes=(classes = nil)
        if classes.nil? || !classes.is_a?(Hash)
          classes = { NameError => "503",
                      TypeError => "503"}
          classes.merge!({ ActiveRecord::RecordNotFound => "400" }) if ActiveRecord.const_defined?(:RecordNotFound)
          classes.merge!({ ActionController::UnknownController => "404" }) if ActionController.const_defined?(:UnknownController)
          classes.merge!({ ActionController::MissingTemplate => "404" }) if ActionController.const_defined?(:MissingTemplate)
          classes.merge!({ ActionController::UnknownAction => "501" }) if ActionController.const_defined?(:UnknownAction)
          classes.merge!({ ActionController::RoutingError => "404" }) if ActionController.const_defined?(:RoutingError)
          @@rails_error_classes = classes
        else
          @@rails_error_classes = classes
        end
      end
      def self.rails_error_classes
        @@rails_error_classes
      end
    EOF
  end
  
  module ClassMethods
    def http_error_codes
      self.class.http_error_codes
    end
    def rails_error_classes
      self.class.rails_error_classes
    end
    def error_layout
      self.class.error_layout
    end

    def consider_local(*args)
      local_addresses.concat(args.flatten.map { |a| IPAddr.new(a) })
    end

    def local_addresses
      addresses = read_inheritable_attribute(:local_addresses)
      unless addresses
        addresses = [IPAddr.new("127.0.0.1")]
        write_inheritable_attribute(:local_addresses, addresses)
      end
      addresses
    end

    def exception_data(deliverer=self)
      if deliverer == self
        read_inheritable_attribute(:exception_data)
      else
        write_inheritable_attribute(:exception_data, deliverer)
      end
    end

  end

  private

    def local_request?
      remote = IPAddr.new(request.remote_ip)
      !self.class.local_addresses.detect { |addr| addr.include?(remote) }.nil?
    end

    def render_error(status_cd, request, exception, file_path = nil)
      status = self.class.http_error_codes[status_cd] ? status_cd + " " + self.class.http_error_codes[status_cd] : status_cd
#Uncomment to get some info about the error handling...
#      puts "[FILE PATH] #{file_path}" if !file_path.nil?
#      logger.error("render_error(#{status_cd}, #{self.class.http_error_codes[status_cd]}) invoked for request_uri=#{request.request_uri} and env=#{request.env.inspect}")
      respond_to do |type|
        type.html { render :file => file_path ? ExceptionNotifier.get_view_path(file_path) : ExceptionNotifier.get_view_path(status_cd), 
                            :layout => self.class.error_layout, 
                            :status => status }
        type.all  { render :nothing => true, 
                            :status => status}
      end
      send_exception_email(exception) if ExceptionNotifier.should_send_email?(status_cd, exception)
    end

    def send_exception_email(exception)
      deliverer = self.class.exception_data
      data = case deliverer
        when nil then {}
        when Symbol then send(deliverer)
        when Proc then deliverer.call(self)
      end
      ExceptionNotifier.deliver_exception_notification(exception, self,
        request, data)
    end

    def rescue_action_in_public(exception)
#Uncomment to get some info about the error handling...
#      puts self.class.rails_error_classes.inspect
#      puts self.class.http_error_codes.inspect
#      puts "[EXCEPTION] #{exception}"
#      puts "[EXCEPTION CLASS] #{exception.class}"
#      puts "[EXCEPTION STATUS_CD] #{self.class.rails_error_classes[exception.class]}" unless self.class.rails_error_classes[exception.class].nil?
      if self.class.rails_error_classes[exception.class].nil?
        render_error("500", request, exception)
      elsif self.class.rails_error_classes[exception.class].blank? || self.class.rails_error_classes[exception.class] == '200'
        render_error("200", request, exception, exception.to_s.delete(':').gsub( /([A-Za-z])([A-Z])/, '\1' << '_' << '\2' ).downcase)
      else
        render_error(self.class.rails_error_classes[exception.class], request, exception)
      end
    end
end
