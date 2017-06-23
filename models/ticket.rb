class Ticket < ActiveRecord::Base
  def close(title, resolution)
    self.closed = true
    self.title = title
    self.resolution = resolution
  end
end
