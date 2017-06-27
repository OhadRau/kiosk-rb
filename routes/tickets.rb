class Kiosk
  get '/ticket/:id' do
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
      site_name: $CONFIG[:site_name]
    }
    slim :ticket, locals: local
  end

  get '/tickets/:ticket_type' do
    type, tickets = case ticket_type
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
      site_name: $CONFIG[:site_name]
    }
  end

  post '/create' do
    if !params.has_key?("name") || !params.has_key?("body")
      flash[:error] = "Ticket is missing required fields. Please try again."
      return redirect '/'
    end

    ticket = Ticket.create({
      name: params[:name],
      body: params[:body],
      asset_tag: if params.has_key?("asset_tag") then params[:asset_tag] else "N/A" end,
      time: Time.now,
      closed: false,
      title: "",
      resolution: "",
      assigned: User.offset(rand(User.count)).first
    })
    ticket.save!

    redirect '/tickets/open'
  end

  post '/close/:id' do
    if !params.has_key?("title") || !params.has_key?("resolution")
      flash[:error] = "Closing a ticket requires a title and resolution! Please try again."
      return redirect '/'
    end

    if !Ticket.exists?(id: id)
      flash[:error] = "That ticket's ID was invalid. Please try again."
      return redirect '/'
    end

    Ticket.where(id: id).update_all(:closed => true, :title => params[:title], :resolution => params[:resolution])
  end
end
