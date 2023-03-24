# Fired when bot leaves the server

require_relative "../EventsHandler.rb"

server_delete_event = proc { |handler|
  handler.server_delete { |event|

    # Remove the db file for that server
    if File.exist?("data/serverdata/#{event.server.id}.db")
      FileUtils.rm("data/serverdata/#{event.server.id}.db")
    end
  }
}

EventsHandler.add_handler(server_delete_event)
