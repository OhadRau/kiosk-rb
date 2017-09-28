require_relative 'accounts'
require_relative 'tickets'

class Kiosk
  get '/' do
    locals = {
      logged_in: User.exists?(email: session[:user_email]),
      site_title: $CONFIG[:site_title],
      min_description_length: $CONFIG[:min_description_length]
    }

    slim :home, locals: locals
  end
end
