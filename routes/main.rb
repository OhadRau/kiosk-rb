require_relative 'accounts' # /signup, /signin, /signout
require_relative 'tickets'  # /tickets, /archive, /create, /close

class Kiosk
  get '/' do
    locals = {
      logged_in: User.exists(email: session[:user_email]),
      site_name: $CONFIG.site_name
    }

    slim :index, locals: locals
  end
end
