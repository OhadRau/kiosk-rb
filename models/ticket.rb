class Ticket < ActiveRecord::Base
  def close(resolution)
    self.closed = true
    self.resolution = resolution
    self.save!
  end

  def printer()
    Prawn::Document.generate("public/stickers/#{id}.pdf", :page_size => [in2pt(2.3125), in2pt(4)], :margin => [in2pt(0.25), in2pt(0.25), in2pt(0.25), in2pt(0.25) ] ) do |pdf|
      pdf.text("<b>Name:</b> #{self.name}", :inline_format => true, :size => 8)
      pdf.text("<b>Description:</b> #{self.body}", :inline_format => true, :size => 8)
      pdf.text("<b>Time:</b> #{self.time.localtime.strftime('%m.%d.%Y %l:%M%P %Z')}", :inline_format => true, :size => 8)
      pdf.text("<b>ID:</b> #{self.id}", :inline_format => true, :size => 8)
      pdf.text("<b>Assigned:</b> #{self.assigned}", :inline_format => true, :size => 8)
      pdf.text("<b>Site:</b> #{$CONFIG[:site_name]}", :inline_format => true, :size => 8)
    end

    `lpr -P '#{$CONFIG[:printer_name]}' public/stickers/#{id}.pdf`

    printed = $?.exitstatus == 0

    # File.delete("public/stickers/#{id}.pdf")

    return printed
  end

  def postToServiceDesk(title, subcategory, item)
    self.closed = true
    self.title = title
    self.save!

    url = URI.parse($CONFIG[:sdp] + '/sdpapi/request')

    input_data = {
      :operation => {
        :details => {
          :requester => $CONFIG[:school_tech],
          :mode => "KIOSK",
          :assets => self.asset_tag,
          :group => "IT School Interns",
          :category => "Student 1:1 Devices",
          :subcategory => subcategory,
          :item => item,
          :subject => self.title,
          :description => "#{self.body} (requested by #{self.name} via #{$CONFIG[:site_title]})",
          :requesttemplate => "Unable to browse",
          :priority => "Normal",
          :site => $CONFIG[:site_title],
          :level => "Tier 3",
          :status => "open",
          :service => "Email"
        }
      }
    }.to_json

    Thread.new do
      req = Net::HTTP::Post.new(url.path)
      req.form_data = {
        :OPERATION_NAME => "ADD_REQUEST",
        :TECHNICIAN_KEY => $CONFIG[:sdpToken],
        :INPUT_DATA => input_data,
        :format => "json"
      }

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # TODO: Verify SSL certificates
      http.start { |http| http.request(req) }
    end
  end
end
