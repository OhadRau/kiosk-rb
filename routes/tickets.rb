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

    if params[:body].length < $CONFIG[:min_description_length]
      flash[:error] = "Description must be at least #{$CONFIG[:min_description_length]} characters long"
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

    flash[:success] = "Your ticket has been submitted!" unless User.exists?(email: session[:user_email])
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
      ticket = Ticket.where(id: id).first

      locals = {
        id: id,
        name: ticket.name,
        asset_tag: ticket.asset_tag,
        body: ticket.body,
        time: ticket.time,
        assigned: ticket.assigned,
        title: ticket.title,
        site_title: $CONFIG[:site_title]
      }
      Prawn::Document.generate("public/stickers/#{id}.pdf", :page_size => [in2pt(2.3125), in2pt(4)] ) do
        text("<b>Name:</b> #{locals[:name]}", :inline_format => true, :size => 8)
        text("<b>Description:</b> #{locals[:body]}", :inline_format => true, :size => 8)
        text("<b>Time:</b> #{locals[:time]}", :inline_format => true, :size => 8)
        text("<b>ID:</b> #{locals[:id]}", :inline_format => true, :size => 8)
        text("<b>Assigned:</b> #{locals[:assigned]}", :inline_format => true, :size => 8)
        text("<b>Site:</b> #{locals[:site]}", :inline_format => true, :size => 8)

        print
      end

      send_file File.join(settings.public_folder, "stickers/#{id}.pdf")

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
