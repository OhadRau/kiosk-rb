class Kiosk
  get '/ticket/:id' do
    return redirect back unless User.exists?(email: session[:user_email])

    id = params[:id]

    unless Ticket.exists?(id: id)
      flash[:error] = "Ticket #{id} does not exist"
      return redirect '/'
    end

    ticket = Ticket.where(id: id).first

    locals = {
      id: id,
      name: ticket.name,
      asset_tag: ticket.asset_tag,
      body: ticket.body,
      time: ticket.time,
      assigned: ticket.assigned,
      closed: ticket.closed,
      title: ticket.title,
      resolution: ticket.resolution,
      logged_in: User.exists?(email: session[:user_email]),
      site_title: $CONFIG[:site_title]
    }

    slim :ticket, locals: locals
  end

  
  get '/tickets' do
    return redirect back unless User.exists?(email: session[:user_email])

    redirect '/tickets/both'
  end

  get '/tickets/:ticket_type' do
    return redirect back unless User.exists?(email: session[:user_email])

    type, tickets = case params[:ticket_type]
      when "open"
        [:open, Ticket.where(closed: false)]
      when "archived"
        [:archived, Ticket.where(closed: true)]
      else
        [:both, Ticket.all]
    end

    locals = {
      ticket_type: type,
      tickets: tickets,
      logged_in: User.exists?(email: session[:user_email]),
      site_title: $CONFIG[:site_title]
    }

    slim :tickets, locals: locals
  end

  post '/create/' do
    if !params.has_key?("name") || !params.has_key?("body")
      flash[:error] = "Ticket is missing required fields. Please try again."
      return redirect '/'
    end

    ticket = Ticket.create({
      name: params[:name],
      body: params[:body],
      asset_tag: if params.has_key?("asset") then params[:asset] else "N/A" end,
      time: Time.now,
      closed: false,
      title: "",
      resolution: "",
      assigned: User.offset(rand(User.count)).first.email
    })
    ticket.save!

    redirect '/tickets/open'
  end

  post '/close/:id' do
    return redirect back unless User.exists?(email: session[:user_email])

    id = params[:id]

    if !params.has_key?("resolution")
      flash[:error] = "Closing a ticket requires a resolution! Please try again."
      return redirect '/'
    end

    if !Ticket.exists?(id: id)
      flash[:error] = "That ticket's ID was invalid. Please try again."
      return redirect '/'
    end

    Ticket.where(id: id).first.close(params[:resolution])

    redirect '/'
  end

  post '/fwd/:id' do
    return redirect back unless User.exists?(email: session[:user_email])

    id = params[:id]

    if !params.has_key?("title")
      flash[:error] = "Forwarding a ticket requires a title! Please try again."
      return redirect '/'
    end

    if !Ticket.exists?(id: id)
      flash[:error] = "That ticket's ID was invalid. Please try again."
      return redirect '/'
    end

    Ticket.where(id: id).first.postToServiceDesk(params[:title])

    redirect '/'
  end
end
