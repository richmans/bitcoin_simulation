require "sqlite3"
require 'active_support/core_ext'

class Wallet
  def initialize(initial_balance)
    @amount_eur = initial_balance
    @amount_bit = 0.0
    @rate = 102.0
    @initial_balance = initial_balance
    @exchange_penalty = 0.016 # calculated from bitonic.nl exchange rates
  end
  
  def update_rate(new_rate)
    @rate = new_rate
  end
  
  def trade_in
    return if @amount_eur == 0
    @amount_bit += @amount_eur / @rate * (1 - @exchange_penalty)
    @amount_eur = 0
    puts "Traded in to a balance of #{@amount_bit}"
  end
  
  def trade_out
    return if @amount_bit == 0
    @amount_eur += @amount_bit * @rate * (1 - @exchange_penalty)
    @amount_bit = 0
    puts "Traded out to a balance of #{@amount_eur}"
  end
  
  def total
    @amount_eur + @amount_bit * @rate
  end
  
  def report
    puts "Wallet started with #{@initial_balance.round(2)} and ended with #{total.round(2)}"
  end
end

class Predictor
  attr_reader :current_date, :prediction_record
  
  def initialize(starting_date)
    @current_date = starting_date
    @db = SQLite3::Database.new "historic_btc_eur.sqlite"
    @last_rate = get_rate(@db)
    @prediction_record = {right:0, wrong: 0}
    @prediction = 1
  end
  
  def rate
    @last_rate
  end
  
  def predict
    @current_date += 1.days
    rate = get_rate(@db)
    if rate == nil
      puts "It is a new day: #{@current_date}, but no record found..."
      @current_date += 1.days
      return 0
    end
    score = get_score(@prediction, @last_rate, rate)
    @prediction_record[score] += 1
    @prediction = (rate > @last_rate) ? 1 : -1
    @prediction_str = (@prediction > 0) ? "up" : "down"
    puts "It is a new day: #{@current_date}, and the rate is #{rate}. I predict it will go #{@prediction_str}"
    @last_rate = rate
    @prediction
  end

  def get_score(prediction, last_rate, rate)
    if prediction > 0
      if rate >= last_rate
        return :right
      else
        return :wrong
      end
    else
      if rate <= last_rate
        return :right
      else
        return :wrong
      end
    end
  end

  def get_rate(db) 
    row = @db.execute( "select rate from history where day=? and month=? and year=?", [@current_date.day, @current_date.month, @current_date.year ])
    row[0][0] rescue nil
  end
  
  def report
    total = @prediction_record[:right] + @prediction_record[:wrong]
    right_pct =  ((@prediction_record[:right].to_f / total) * 100).round
    puts "In #{total} guesses, I was right #{right_pct}% of the time."
  end
end

starting_date = DateTime.new(2015,1,1)
ending_date = DateTime.new(2016,1,1)
predictor = Predictor.new(starting_date)
wallet = Wallet.new(100.0)
while predictor.current_date < ending_date do
  prediction = predictor.predict
  rate = predictor.rate
  wallet.update_rate(rate)
  if prediction > 0
    wallet.trade_in
  elsif prediction < 0
    wallet.trade_out
  end
end

predictor.report
wallet.report