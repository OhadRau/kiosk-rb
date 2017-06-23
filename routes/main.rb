require_relative 'accounts' # /signup, /signin, /signout
require_relative 'tickets'  # /tickets, /archive, /create, /close

class Kiosk
  get '/' do
    locals = {
      logged_in: false
      site_name: $CONFIG.site_name
    }

    slim :index, locals: locals
  end
end
