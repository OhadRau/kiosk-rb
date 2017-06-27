require_relative 'accounts'
require_relative 'tickets'

class Kiosk
  get '/' do
    locals = {
      logged_in: User.exists?(email: session[:user_email]),
      site_name: $CONFIG[:site_name]
    }

    slim :home, locals: locals
  end
end
