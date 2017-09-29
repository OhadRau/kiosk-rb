# kiosk-rb
Kiosk for student device support in Ruby

## What does it do?
kiosk-rb provides a streamlined solution for an in-school kiosk for student device support,
allowing students to submit issues that they encounter and technicians to log and manage these
support requests.

### Features:
* Simple per-school configuration
* ServiceDesk Plus integration
* Web-based user interface for remote access
* Student/administrator privileges
* Sticker printing for submitted tickets

## ServiceDesk Plus Integration:
kiosk-rb uses the ServiceDesk Plus REST API in order to allow technicians to escalate tickets
to a full-featured ServiceDesk Plus appliance. Ticket escalation is done through the '/sdpapi/request'
POST end-point. The following fields are submitted:
* Mode: "KIOSK"
* Assets: Ticket asset tag
* Group: "IT School Interns"
* Category: "Student 1:1 Devices"
* Subcategory: "Hardware"
* Item: "Unable to browse"
* Subject: Ticket title
* Description: "<ticket body> (requested by <request name> via <Config site_title>)"
* RequestTemplate: "Unable to browse"
* Priority: "Normal"
* Site: Config site_title
* Level: "Tier 3"
* Status: "open"
* Service: "Email"

## Configuration Options:
* `connection`:
  + `adapter`: Type of database being used (default `sqlite3`)
  + `database`: Name of database file (default `kiosk.db`)
* `site_name`: The name of installation site on ServiceDesk (i.e. your school)
* `site_title`: The website title (e.g. "Riverwood Geek Squad")
* `min_description_length`: The minimum amount of characters for an issue description submitted by students
* `initial_users`: The number of administrator account keys to create on the first run of the program
* `printer_name`: The name of the sticker printer in CUPS
* `sdp`: The base URL to your ServiceDesk Plus installation
* `sdpToken`: The API key for your ServiceDesk Plus installation
* `secret`: The secret token used to encrypt session data

## Setup/Installation:
* Generate an API key using ServiceDesk Plus
* Install an operating system compatible with CUPS (recommended: Alpine Linux)
* Install Ruby, Sqlite3, CUPS
* Configure your default printer using CUPS
* If using external storage media, create a kiosk account with a home directory on the external media
* Set all necessary options in the `config.yml` file
* Run `sqlite3 kiosk.db <models/schemas/sqlite.sql` to initialize the database
* Run `bundle install` to install all necessary packages for the program
* Start the program with `rackup` (recommended: make the program run on startup using your init system)
