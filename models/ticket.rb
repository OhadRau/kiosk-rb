class Ticket < ActiveRecord::Base
  def close(resolution)
    self.closed = true
    self.resolution = resolution
    self.save!
  end

  def printer()

    locals = {
      id: id,
      name: self.name,
      asset_tag: self.asset_tag,
      body: self.body,
      time: self.time,
      assigned: self.assigned,
      title: self.title,
      site_title: $CONFIG[:site_title]
    }
    Prawn::Document.generate("public/stickers/#{id}.pdf", :page_size => [in2pt(2.3125), in2pt(4)] ) do
      text("<b>Name:</b> #{locals[:name]}", :inline_format => true, :size => 8)
      text("<b>Description:</b> #{locals[:body]}", :inline_format => true, :size => 8)
      text("<b>Time:</b> #{locals[:time]}", :inline_format => true, :size => 8)
      text("<b>ID:</b> #{locals[:id]}", :inline_format => true, :size => 8)
      text("<b>Assigned:</b> #{locals[:assigned]}", :inline_format => true, :size => 8)
      text("<b>Site:</b> #{locals[:site]}", :inline_format => true, :size => 8)
    end

    system "lpr -p '#{$CONFIG[:printer_name]}' public/stickers/#{id}.pdf"

    if $?.exitstatus > 0
      printed = false
    else
      printed = true
    end

    File.delete("public/stickers/#{id}.pdf")
    return printed

  end

  def postToServiceDesk(title)
    self.closed = true
    self.title = title
    self.save!

    url = URI.parse($CONFIG[:sdp] + '/sdpapi/request')

    input_data = {
      :operation => {
        :details => {
          :mode => "KIOSK",
          :assets => self.asset_tag,
          :group => "IT School Interns",
          :category => "Student 1:1 Devices",
          :subcategory => "Hardware",
          :item => "Unable to browse",
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
