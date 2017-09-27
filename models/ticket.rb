class Ticket < ActiveRecord::Base
  def close(resolution)
    self.closed = true
    self.resolution = resolution
    self.save!
  end

  def postToServiceDesk(title)
    self.closed = true
    self.title = title
    self.save!

    url = URI.parse($CONFIG[:sdp] + '/sdpapi/request')

    input_data = {
      :operation => {
        :details => {
          :requester => self.name + " (via Kiosk)",
          :subject => self.title,
          :description => self.body,
          :requesttemplate => "Unable to browse",
          :priority => "Normal",
          :site => $CONFIG[:site_title],
          :group => "Unable to browse",
          :technician => self.assigned,
          :level => "Tier 3",
          :status => "open",
          :service => "Email"
        }
      }
    }.to_json

    #Thread.new do
      req = Net::HTTP::Post.new(url.path)
      req.form_data = {
        :OPERATION_NAME => "ADD_REQUEST",
        :TECHNICIAN_KEY => $CONFIG[:sdpToken],
        :INPUT_DATA => input_data
      }

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # TODO: Verify SSL certificates
      http.set_debug_output($stdout) 
      http.start { |http| http.request(req) }
    #end
  end
end
