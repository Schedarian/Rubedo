module Database
  def self.check_db(server)
    unless File.exist?("data/serverdata/#{server}.db")
      FileUtils.touch("#{server}.db")
      FileUtils.mv("#{server}.db", "data/serverdata/#{server}.db")
    end
    db = SQLite3::Database.open "data/serverdata/#{server}.db"
    db.execute("CREATE TABLE IF NOT EXISTS warns(userid TEXT, reason TEXT, issuedby TEXT, timestamp INTEGER)")
    db.close if db
  end

  def self.refresh_data(server)
    time = Time.now.to_i - 2592000 #delete warn if timestamp + 30 days is lower than time.now
    db = SQLite3::Database.open "data/serverdata/#{server}.db"
    db.execute "DELETE FROM warns WHERE timestamp < ?", time
  end

  def self.insert_warning(server, user, reason, issuedby, timestamp)
    Database.check_db(server)
    Database.refresh_data(server)
    db = SQLite3::Database.open "data/serverdata/#{server}.db"
    count = db.execute "SELECT COUNT (*) FROM warns WHERE userid = ?", user
    db.execute("INSERT INTO warns(userid, reason, issuedby, timestamp) VALUES (?, ?, ?, ?)", user, reason, issuedby, timestamp) if count[0][0] < 5
    return count[0][0]
  end

  def self.remove_warning(server, user, number)
    Database.check_db(server)
    Database.refresh_data(server)
    db = SQLite3::Database.open "data/serverdata/#{server}.db"
    count = db.execute "SELECT COUNT (*) FROM warns WHERE userid = ?", user
    return nil if count == 0
    timestamps = db.execute "SELECT timestamp FROM warns WHERE userid = ?", user
    number = timestamps.size if number.nil?
    number = timestamps.size if number > timestamps.size
    id = timestamps[number - 1]
    db.execute "DELETE FROM warns WHERE timestamp = ?", id
    return number
  end

  def self.clear_warnings(server, user)
    db = SQLite3::Database.open "data/serverdata/#{server}.db"
    db.execute "DELETE FROM warns WHERE userid = ?", user
  end

  def self.get_warnings(server, user)
    # get data lol
    db = SQLite3::Database.open "data/serverdata/#{server}.db"
    count = db.execute "SELECT COUNT (*) FROM warns WHERE userid = ?", user
    warnings = db.execute "SELECT reason, issuedby, timestamp FROM warns WHERE userid = ?", user
    return [count[0][0], warnings]
  end

  def self.drop_warnings(server)
    db = SQLite3::Database.open "data/serverdata/#{server}.db"
    db.execute "DELETE FROM warns"
  end
end

#CREATE TABLE IF NOT EXISTS warns(userid TEXT, reason TEXT, issuedby TEXT, timestamp TEXT);
#INSERT INTO warns(userid, reason, issuedby, timestamp) VALUES ('123', 'sus amogus', 'imposter', '456');
#INSERT INTO warns(userid, reason, issuedby, timestamp) VALUES ('123', 'amogus sus', 'sus', '789');
#INSERT INTO warns(userid, reason, issuedby, timestamp) VALUES ('123', 'sussus amongus', 'vent', '000');
#SELECT reason, issuedby, timestamp FROM warns WHERE userid = '123';
