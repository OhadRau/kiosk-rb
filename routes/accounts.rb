class Kiosk
  get '/signup' do
    locals = {
      logged_in: false,
      site_name: $CONFIG.site_name
    }
    slim :signup, locals: locals
  end

  post '/signup' do
    if !params.has_key("firstname") || !params.has_key("lastname") || !params.has_key?("email") || !params.has_key?("password") || !params.has_key("code")
      flash[:error] = "Missing required field!"
      return redirect '/signup'
    end

    if User.exists?(email: email)
      flash[:error] = "That email is already in use. Please try another email."
      return redirect '/signup'
    end

    if !Code.validate(params[:code])
      flash[:error] = "Your sign-up code is invalid. Please try another code."
      return redirect '/signup'
    end

    user = User.create({
      firstname: params[:firstname],
      lastname: params[:lastname],
      email: params[:email],
      password: "TEMP"
    })
    user.password = params[:password]
    user.save!

    redirect '/'
  end

  get '/signin' do
    locals = {
      logged_in: false,
      site_name: $CONFIG.site_name
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

    session[:user_email] = email
    redirect '/'
  end

  post '/signout' do
    session.clear
    redirect '/'
  end
end