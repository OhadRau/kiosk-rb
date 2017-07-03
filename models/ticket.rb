class Ticket < ActiveRecord::Base
  def close(resolution)
    self.closed = true
    self.resolution = resolution
  end

  def postToServiceDesk(title)
    self.closed = true

    url = URI.parse($CONFIG[:sdp] + '/sdpapi/request')
    self.title = title

    input_data = {
      :operation => {
        :details => {
          :requester => self.name + " (via Kiosk)",
          :subject => self.title,
          :description => self.body,
          :requesttemplate => "Unable to browse",
          :priority => "Normal",
          :site => "Unable to browse",
          :group => "Unable to browse",
          :technician => self.assigned,
          :level => "Tier 3",
          :status => "open",
          :service => "Email"
        }
      }
    }.to_json

    Thread.new do
      Net::HTTP.post_form(url, {
        :OPERATION_NAME => "ADD_REQUEST",
        :INPUT_DATA => input_data
      })
    end
  end
end
