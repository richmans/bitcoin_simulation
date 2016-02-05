require "sqlite3"

# imports data from https://api.bitcoinaverage.com/history/EUR/per_day_all_time_history.csv
db = SQLite3::Database.new "historic_btc_eur.sqlite"
db.execute("delete from history;")

File.open("historic_btc_eur.csv", "r").each_line do |line|
  # skips the first line.
  next if line[0] != "2"
  input = line.split(",").to_a
  date, time = input[0].split(" ")
  date = date.split("-").map(&:to_i)
  time = time.split(":").map(&:to_i)
  value = input[3].to_f
  volume = input[4].to_f
  record = date + time + [value, volume]
  db.execute "insert into history values ( ?, ?, ?, ?, ?, ?, ?, ? )", record
end
puts "Done."