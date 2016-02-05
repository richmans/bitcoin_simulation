# Bitcoin trader simulation
This is a simple ruby script to answer the following question:

# Question
What would have happened had i invested 100 euros into bitcoins on january first, 2015, and used a simple prediction algorithm to decide once per day to buy in or out, until the end of the year?

# Answer
I would end up with 37.93 euros left. Basically you can make quite a nice prediction, but because of the exchange fees, you don't profit from it.

# usage:
First download this https://api.bitcoinaverage.com/history/EUR/per_day_all_time_history.csv and save it as historic\_btc\_eur.csv

Next, run 

    ruby import_historic_btc_eur.rb
    
And then
    
    ruby simulate_prediction.rb
    
And then...

-> Well not profit, but at least you didn't lose anything!
