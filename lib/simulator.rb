require 'rational'
class Simulator
  class Card
    # 2 3 4 5 6 7 8 9 10 11 12 13 14
    # 2 3 4 5 6 7 8 9 10 J   Q  K A
    attr_reader :rank, :suit
    attr_accessor :wins
    def initialize(rank, suit)
      @rank, @suit, @wins = rank, suit, 0
      # A little nicety to allow 1 to be used for the Ace but give it high rank
      @rank = 14 if rank == 1
    end
    
    # We just want to ensure that clubs are going to have a lower lead_value than any other suit.
    def lead_value
      club? ? rank : rank + 13
    end
    
    def club?
      suit == :C
    end
    
    def ==(other)
      rank = other.rank && suit == other.suit
    end
    
    def rank_string
      [
        "  ", "  ", " 2", " 3", " 4", " 5", " 6",
        " 7", " 8", " 9", "10", " J", " Q", " K", " A"
        ][rank]
    end
    
    def to_s
      "#{rank_string}#{suit} #{rank}"
    end
  end
  
  attr_reader :initial_deck, :min_wins, :clubs
  attr_accessor :hands_played
  
  def initialize(min_wins = 1000)
    @min_wins = min_wins
    @hands_played = 0
    @clubs = (1..13).map {|rank| Card.new(rank, :C)}
    @initial_deck = [
      (1..13).map {|rank| Card.new(rank, :S)},
      (1..13).map {|rank| Card.new(rank, :H)},
      (1..13).map {|rank| Card.new(rank, :D)},
      clubs
    ].flatten
  end
  
  def Simulator.card(rank, suit)
    Card.new(rank, suit)
  end
  
  def lead_card(hand)
    hand.sort_by {|card| card.lead_value}.select {|card| card.club?}.first
  end
  
  def shuffle
    initial_deck.sort_by { rand(1000) }
  end
  
  def hands
    shuffle.each_slice(13)
  end
  
  def lead_cards
    winner = hands.map {|hand|
      lead_card(hand)
    }
  end
  
  def record_winner(card)
    card.wins += 1
  end
  
  def least_wins
    clubs.map {|card| card.wins}.min
  end
  
  def winning_card(leads)
    leads.compact.sort_by {|c| c.rank}.last
  end
  
  def play_hand
    record_winner(winning_card(lead_cards))
    self.hands_played += 1
  end
  
  def report(time)
    puts "after playing #{hands_played} hands in #{time} seconds - #{hands_played/time} hands per second:"
    @clubs.sort_by {|c| c.rank}.each do |card|
      winning_probability = Rational(card.wins, hands_played)
      puts "#{card}: won #{
         card.wins} times, probability is #{
         winning_probability}(#{
         "%06.4f" % winning_probability.to_f
         })"
    end
  end
  
  def run
    srand
    start_time = Time.now
    while least_wins < min_wins
      play_hand
      # puts "hands played: #{hands_played} least_wins: #{least_wins}"
    end
    report(Time.now - start_time)
  end
end
  