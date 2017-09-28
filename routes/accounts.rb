class Kiosk
  get '/signup' do
    locals = {
      logged_in: false,
      site_title: $CONFIG[:site_title]
    }
    slim :signup, locals: locals
  end

  #sign up code
  post '/signup' do
    #checks for required field
    if !params.has_key?("firstname") || !params.has_key?("lastname") || !params.has_key?("email") || !params.has_key?("password") || !params.has_key?("code")
      flash[:error] = "Missing required field!"
      return redirect '/signup'
    end

    #checks for required field lengths
    if params[:firstname].length == 0
      flash[:error] = "Missing required field (First Name)"
      return redirect '/signup'      
    end
    if params[:lastname].length == 0 
      flash[:error] = "Missing required field (Last Name)"
      return redirect '/signup'
    end
    if params[:email].length == 0
      flash[:error] = "Missing required field (Email)" 
      return redirect '/signup'
    end
    if params[:password].length == 0
      flash[:error] = "Missing required field (Password)" 
      return redirect '/signup' 
    end
    if params[:code].length == 0
      flash[:error] = "Missing required field (Code)"
      return redirect '/signup'
    end
    
    #checks if email has already been used
    if User.exists?(email: params[:email])
      flash[:error] = "That email is already in use. Please try another email."
      return redirect '/signup'
    end

    #checks if sign-up code is valid
    if !Code.validate(params[:code])
      flash[:error] = "Your sign-up code is invalid. Please try another code."
      return redirect '/signup'
    end

    #creates new user
    user = User.create({
      firstname: params[:firstname],
      lastname: params[:lastname],
      email: params[:email],
      passwordHash: "TEMP"
    })
    user.password = params[:password]
    user.save!

    redirect '/'
  end

  get '/signin' do
    locals = {
      logged_in: false,
      site_title: $CONFIG[:site_title]
    }
    slim :signin, locals: locals
  end

  post '/signin' do
    if !params.has_key?("email") || !params.has_key?("password")
      flash[:error] = "Missing email or password!"
      return redirect '/signin'
    end

    if !User.exists?(params[:email]) || !User.authorized?(params[:email], params[:password])
      flash[:error] = "Incorrect email or password!"
      return redirect '/signin'
    end

    session[:user_email] = params[:email]
    redirect '/'
  end

  get '/signout' do
    session.clear
    redirect '/'
  end
end
