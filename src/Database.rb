module Database
  def self.check_db(bot)
    bot.servers.each { |key, value|
      unless File.exist?("data/serverdata/#{key}.db")
        FileUtils.touch("#{key}.db")
        FileUtils.mv("#{key}.db", "data/serverdata/#{key}.db")
        db = SQLite3::Database.open "data/serverdata/#{key}.db" # Key is the server id
        db.execute("CREATE TABLE IF NOT EXISTS serversettings(serverid TEXT, setting TEXT, value TEXT)")
        db.execute("CREATE TABLE IF NOT EXISTS warns(userid TEXT, reason TEXT, issuedby TEXT, timestamp INTEGER)")
        ServerSettings.create_defaults(key.to_s)
        #db.close if db
      end
    }
  end

  module Warnings
    def self.refresh_data(server)
      time = Time.now.to_i - 2592000 # Delete warn if timestamp + 30 days is lower than time.now
      db = SQLite3::Database.open "data/serverdata/#{server}.db"
      db.execute "DELETE FROM warns WHERE timestamp < ?", time
    end

    def self.insert_warning(server, user, reason, issuedby, timestamp)
      self.refresh_data(server)

      db = SQLite3::Database.open "data/serverdata/#{server}.db"
      count = db.execute "SELECT COUNT (*) FROM warns WHERE userid = ?", user
      db.execute("INSERT INTO warns(userid, reason, issuedby, timestamp) VALUES (?, ?, ?, ?)", user, reason, issuedby, timestamp) if count[0][0] < 5

      return count[0][0] # Warn count before the last warning, so add one to get the actual count
    end

    def self.remove_warning(server, user, number)
      self.refresh_data(server)

      db = SQLite3::Database.open "data/serverdata/#{server}.db"
      count = db.execute "SELECT COUNT (*) FROM warns WHERE userid = ?", user
      return nil if count == 0 # Nil means user was not found in the database

      # I use timestamps as id for the warnings
      timestamps = db.execute "SELECT timestamp FROM warns WHERE userid = ?", user

      # Set the last warning to be removed if number is not provided
      number ||= timestamps.size

      # And if number is provided, check whether it is lower than the warn count, then do the stuff
      number = timestamps.size if number > timestamps.size
      id = timestamps[number - 1]
      db.execute "DELETE FROM warns WHERE timestamp = ?", id
      return number # Returns which warning was deleted
    end

    def self.clear_warnings(server, user) # Removes all warnings for the given user
      self.refresh_data(server)

      db = SQLite3::Database.open "data/serverdata/#{server}.db"
      db.execute "DELETE FROM warns WHERE userid = ?", user
    end

    def self.get_warnings(server, user) # Gets all warnings for the given user
      self.refresh_data(server)

      db = SQLite3::Database.open "data/serverdata/#{server}.db"
      count = db.execute "SELECT COUNT (*) FROM warns WHERE userid = ?", user
      warnings = db.execute "SELECT reason, issuedby, timestamp FROM warns WHERE userid = ?", user
      return [count[0][0], warnings]
    end

    def self.drop_warnings(server) # Removes all warnings for the given server
      db = SQLite3::Database.open "data/serverdata/#{server}.db"
      db.execute "DELETE FROM warns"
    end
  end

  module Starboard # TODO: Add Starboard, works with events, seprarte table for starboard channels because more convenient? idk
  end

  module ServerSettings
    def self.create_defaults(server) # Creates the default settings for the given server
      db = SQLite3::Database.open "data/serverdata/#{server}.db"
      db.execute "INSERT INTO serversettings(serverid, setting, value) VALUES (?, ?, ?)", server, "warnperms", "ban_members"
      db.execute "INSERT INTO serversettings(serverid, setting, value) VALUES (?, ?, ?)", server, "embedperms", "manage_messages"
      db.execute "INSERT INTO serversettings(serverid, setting, value) VALUES (?, ?, ?)", server, "logchannel", "0" # Set to 0 to disable logging
      db.execute "INSERT INTO serversettings(serverid, setting, value) VALUES (?, ?, ?)", server, "starboardchannel", "0" # Set to 0 to disable starboard
      db.execute "INSERT INTO serversettings(serverid, setting, value) VALUES (?, ?, ?)", server, "starboardcount", "10" # Default
    end

    def self.delete_settings(server)
      db = SQLite3::Database.open "data/serverdata/#{server}.db"
      db.execute "DELETE FROM serversettings"
    end

    def self.get_setting(server, setting) # Get setting for the given server
      db = SQLite3::Database.open "data/serverdata/#{server}.db"
      res = db.execute "SELECT value FROM serversettings WHERE serverid = ? AND setting = ?", server, setting
      return res.flatten.first.to_sym
    end

    def self.set_setting(server, setting, value) # Set for the given server
      db = SQLite3::Database.open "data/serverdata/#{server}.db"
      db.execute "UPDATE serversettings SET value = ? WHERE serverid = ? AND setting = ?", value, server, setting
    end
  end
end
