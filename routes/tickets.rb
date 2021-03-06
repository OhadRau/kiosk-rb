include Prawn::Measurements

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
      site_title: $CONFIG[:site_title],
      categories: $CONFIG[:sdpcategories],
      items: $CONFIG[:sdpitems]
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

    if params[:body].length < $CONFIG[:min_description_length]
      flash[:error] = "Description must be at least #{$CONFIG[:min_description_length]} characters long"
      return redirect '/'
    end


    ticket = Ticket.create({
      name: params[:name],
      body: params[:body],
      asset_tag: if params.has_key?("asset") then params[:asset] else "N/A" end,
      time: Time.now.localtime("-04:00"),
      closed: false,
      title: "",
      resolution: "",
      assigned: User.offset(rand(User.count)).first.email
    })
    id = ticket[:id]
    ticket.save!
    printer = Ticket.where(id: id).first.printer()

    flash[:success] = "Your ticket has been submitted!"

    case printer
    when true
      flash[:success] = "Please pick your ticket up from the label printer and affix it to your device." unless User.exists?(email: session[:user_email])
    when false
      flash[:error] = "There has been a printer error. Please alert your kiosk manager." unless User.exists?(email: session[:user_email])
    end

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

  post '/print/:id' do
      return redirect back unless User.exists?(email: session[:user_email])

      id = params[:id]

      printer = Ticket.where(id: id).first.printer()

      case printer
      when true
        flash[:success] = "Sent to printer!"
      when false
        flash[:error] = "There has been a printer error"
      end

      redirect "/ticket/#{id}"

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

    Ticket.where(id: id).first.postToServiceDesk(params[:title], params[:category], params[:item])

    redirect '/'
  end
end
