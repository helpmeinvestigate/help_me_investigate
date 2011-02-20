require 'pathname'

# Copyright (c) 2005 Jamis Buck
# Portions Copyright (c) 2008 Peter Boling
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
class ExceptionNotifier < ActionMailer::Base
  @@sender_address = %("#{RAILS_ENV.capitalize} Error" <errors@default.com>)
  cattr_accessor :sender_address

  @@exception_recipients = []
  cattr_accessor :exception_recipients

  @@email_prefix = "[#{RAILS_ENV.capitalize} ERROR] "
  cattr_accessor :email_prefix

  @@sections = %w(request session environment backtrace)
  cattr_accessor :sections

  @@render_only = false
  cattr_accessor :render_only

  @@view_path = nil
  cattr_accessor :view_path

  #Emailed Error Notification will be sent if the error code matches one of the following error codes
  @@send_email_error_codes = %W( 405 500 503 )
  cattr_accessor :send_email_error_codes

  #Emailed Error Notification will be sent if the error class matches one of the following error error classes
  @@send_email_error_classes = %W( )
  cattr_accessor :send_email_error_classes

  self.template_root = "#{File.dirname(__FILE__)}/../views"

  def self.reloadable?() false end

  def self.get_view_path(status_cd)
    if File.exist?("#{RAILS_ROOT}/public/#{status_cd}.html")
      "#{RAILS_ROOT}/public/#{status_cd}.html"
    elsif !view_path.nil? && File.exist?("#{RAILS_ROOT}/#{view_path}/#{status_cd}.html")
      "#{RAILS_ROOT}/#{view_path}/#{status_cd}.html"
    elsif File.exist?("#{RAILS_ROOT}/vendor/plugins/super_exception_notifier/views/exception_notifiable/#{status_cd}.html")
      "#{RAILS_ROOT}/vendor/plugins/super_exception_notifier/views/exception_notifiable/#{status_cd}.html"
    else 
      "#{RAILS_ROOT}/vendor/plugins/super_exception_notifier/views/exception_notifiable/500.html"
    end
  end

  def self.should_send_email?(status_cd, exception)
    !self.render_only && (self.send_email_error_codes.include?(status_cd) || self.send_email_error_classes.include?(exception))
  end

  def exception_notification(exception, controller, request, data={})
    content_type "text/plain"

    subject    "#{email_prefix}#{controller.controller_name}##{controller.action_name} (#{exception.class}) #{exception.message.inspect}"

    recipients exception_recipients
    from       sender_address

    body       data.merge({ :controller => controller, :request => request,
                  :exception => exception, :host => (request.env["HTTP_X_FORWARDED_HOST"] || request.env["HTTP_HOST"]),
                  :backtrace => sanitize_backtrace(exception.backtrace),
                  :rails_root => rails_root, :data => data,
                  :sections => sections })
  end

  private

    def sanitize_backtrace(trace)
      re = Regexp.new(/^#{Regexp.escape(rails_root)}/)
      trace.map { |line| Pathname.new(line.gsub(re, "[RAILS_ROOT]")).cleanpath.to_s }
    end

    def rails_root
      @rails_root ||= Pathname.new(RAILS_ROOT).cleanpath.to_s
    end

end
