require "lib/simulator.rb"

describe Simulator do
  def hand(cards)
    cards.map {|rank, suit| Simulator.card(rank, suit)}
  end
  
  def club(rank)
    Simulator.card(rank, :C)
  end

  before(:each) do
    @it = Simulator.new
  end

  context "#lead_card" do
    it "should return nil for a hand with no clubs" do

      @it.lead_card(hand([[1, :S], [2, :H], [3, :D]])).should be_nil
    end

    it "should return the low club if there is one" do
      @it.lead_card(hand([[2, :C], [2, :H], [3, :C]])).should == club(2)
    end

    it "should treat the ace of clubs as a high card" do
      @it.lead_card(hand([[1, :C], [2, :H], [3, :C]])).should == club(2)
    end
  end

  context "#initial_deck" do
    before(:each) do
      @initial_deck = @it.initial_deck
    end

    it "should have 52 cards" do
      @initial_deck.size.should == 52
    end

    it "should have 13 spades" do
      @initial_deck.select {|card| card.suit == :S}.size.should == 13
    end

    it "should have 13 hearts" do
      @initial_deck.select {|card| card.suit == :H}.size.should == 13
    end

    it "should have 13 diamonds" do
      @initial_deck.select {|card| card.suit == :D}.size.should == 13
    end

    it "should have 13 clubs" do
      @initial_deck.select {|card| card.suit == :C}.size.should == 13
    end

    it "should have unique cards" do
      @initial_deck.uniq.size.should == 52
    end
  end

  describe "shuffle" do
    it "should sort using the initial deck" do
      @it.initial_deck.should_receive(:sort_by)
      @it.shuffle
    end

    it "should sort randomly" do
      @it.should_receive(:rand).with(1000).exactly(52).times.and_return(rand(1000))
      @it.shuffle
    end

    it "should leave the initial deck unchanged" do
      old_initial_deck = @it.initial_deck
      @it.shuffle
      @it.initial_deck.should == old_initial_deck
    end
  end

  context "#hands" do
    # To simplify dealing we simply divide the shuffled deck into four hands,
    # rather than dealing one card at a time to each player,
    # This shouldn't affect the probabilities, since there is a 1-1 mapping to another permutation
    # which would give the same dealt hands.
    before(:each) do
      @it.stub(:shuffle).and_return((1..52).to_a)
    end

    it "should produce four hands" do
      @it.hands.to_a.should == [
        (1..13).to_a,
        (14..26).to_a,
        (27..39).to_a,
        (40..52).to_a
      ]
    end
  end
  
  context "winning_card" do
    it "should return the lead club with the highest rank" do
      expected = club(1)
      @it.winning_card([club(2), expected, club(4), club(5)]).should == expected      
    end
  end

  context "play_hand" do
    context "with stubbed win recording" do
      before(:each) do
        @it.stub(:record_winner)
        @it.stub(:report)
      end

      it "should shuffle the deck" do
        @it.stub(:lead_card)
        @it.should_receive(:shuffle).and_return((1..52).to_a)
        @it.play_hand
      end

      it "should get the lead_card for each hand" do
        @it.stub(:hands).and_return([:hand])
        @it.should_receive(:lead_card).with(:hand).and_return(Simulator.card(2, :C))
        @it.play_hand
      end

      it "should record the winning card" do
        @it.stub(:lead_cards).and_return([
           Simulator.card(2, :C), 
           Simulator.card(3,:C)],
           winning_card = Simulator.card(5, :C),
           Simulator.card(4, :C)
           )
        @it.should_receive(:record_winner).with(winning_card)
        @it.play_hand
      end
    end

    it "should increment the number of hands_played" do
      lambda {@it.play_hand}.should change(@it, :hands_played).by(1)
    end
  end
  
  context "least_wins" do
    it "should return the lowest winning count for all clubs" do
      counts = [2, 3, 4, 1, 5, 7, 6, 9, 8, 11, 10, 10, 3]
      counts.each_with_index { |count, i| @it.clubs[i].wins = count }
      @it.least_wins.should == counts.min
    end
  end
  
  context "#run" do
    before(:each) do
      @it.stub(:report)
    end
    it "should stop when all clubs have won at least the minimum number of times" do
      @it.stub(:least_wins).and_return(@it.min_wins)
      @it.should_not_receive(:play_hand)
      @it.run
    end
    
    it "should play a hand if a club has not won the minumum number of times" do
      @it.stub(:least_wins).and_return(@it.min_wins-1, @it.min_wins)
      @it.should_receive(:play_hand).once
      @it.run
     end
  end
end
