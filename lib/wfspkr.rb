#encoding: UTF-8
#
#  wfspkr.rb: Wildcard Five Stud Poker library. For Ruby 1.9.1
#  Requires a unicode enabled terminal for testing. 
#  
#  
#  Copyright (c) 2010 Beoran (beoran@rubyforge.org)
# 
#  This software is provided 'as-is', without any express or implied
#  warranty. In no event will the authors be held liable for any damages
#  arising from the use of this software.
# 
#  Permission is granted to anyone to use this software for any purpose,
#  including commercial applications, and to alter it and redistribute it
#  freely, subject to the following restrictions:
# 
#     1. The origin of this software must not be misrepresented; you must not
#     claim that you wrote the original software. If you use this software
#     in a product, an acknowledgment in the product documentation would be
#     appreciated but is not required.
# 
#     2. Altered source versions must be plainly marked as such, and must not
#     be misrepresented as being the original software.
# 
#     3. This notice may not be removed or altered from any source
#     distribution.
#



# Wildcard five stud poker
module Wfspkr
  # If it's OK to use unicode suit symbols in output or not.
  SUIT_UNICODE_OK = true
 
 
  # QuickSort (in place) for Ruby
  # based on http://rubyforge.org/snippet/detail.php?type=snippet&id=109
  # by Abdu Chadili (BSD license)
  #
  # accepts an array or a string
  # helper function for quicksort
  def partition(list, left, right, pindex)
    pvalue = list[pindex]
    swap(list, pindex, right)
    sindex = left
    for i in left .. right-1
	if list[i] <= pvalue
	    swap(list, sindex, i)
	    sindex = sindex + 1
	end
    end
    swap(list, right, sindex)
    return sindex
  end

  # Quicksort helper function
  def swap (arr, l, r)
    tmp = arr [l]
    arr[l] = arr[r]
    arr[r] = tmp
  end
  
  # The quicksort itself
  def quicksort!(list, left = nil , right = nil)
    left  ||= 0
    right ||= list.size - 1
    if (right > left)
      pIndex = left
      newPindex = partition(list, left, right, pIndex)
      quicksort!(list, left, newPindex-1)
      quicksort!(list, newPindex+1, right)
    end	  
  end
  
  # Out of band quicksort() 
  def quicksort(list) 
    aid = list.dup
    quicksort!(aid)
    return aid
  end

 
  
  # The rank of a card. It was not in the specs, but it's 
  # cleaner to define a spearate class than to use a string or such 
  class Rank
    include Comparable
    
    # Long name of the rank
    attr_reader :name
    # Short, symbolic name of the rank (123456789TJKQA)
    attr_reader :symbol
    # Value of the rank (from 2 though 14) 
    attr_reader :value

    # Initializes the rank with it's name, value and symbol.
    # Ranks are immutable.
    def initialize(name, value, symbol = nil) 
      @name   = name.to_s
      @value  = value.to_i
      @symbol = symbol ? symbol.to_s : @value.to_s
    end
    
    # Converts the rank to a String representation
    def to_s
      return self.symbol
    end
    
    # Inspect the rank
    def inspect
      return "<Rank: #@name #@value #@symbol>"
    end
    
    # Compares the rank with the other rank 
    def <=>(other)
      return self.value <=> other.value
    end
    
    # Returns the next rank (one up)
    def next_rank()
      return NEXT_RANK[self]
    end
    
    # Returns the previous rank (one down)
    def previous_rank()
      return PREVIOUS_RANK[self]
    end
    
    # Returns true if the other rank follows this one, false if not 
    def next?(other)
      return self.next_rank == other 
    end
    
    # Returns true if the other rank comes before this one, false if not 
    def previous?(other)
      return self.previous_rank == other 
    end
    
    # Generate the rank objects. 
    Ace    = Rank.new(:Ace  , 14, :A) 
    King   = Rank.new(:King , 13, :K)
    Queen  = Rank.new(:Queen, 12, :Q)
    Jack   = Rank.new(:Jack , 11, :J)
    Ten    = Rank.new(:Ten  , 10, :T)
    Nine   = Rank.new(:Nine ,  9)
    Eight  = Rank.new(:Eight,  8)
    Seven  = Rank.new(:Seven,  7)
    Six    = Rank.new(:Six  ,  6)
    Five   = Rank.new(:Five ,  5)
    Four   = Rank.new(:Four ,  4)
    Three  = Rank.new(:Three,  3)
    Two    = Rank.new(:Two  ,  2)
    
    # All ranks
    RANKS  = [ Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, 
               Jack, Queen, King, Ace ]
               
    # Helper for Rank#next_rank and Rank#next?
    NEXT_RANK = {  
      Ace   => Two, Two => Three, Three => Four , Four => Five, 
      Five  => Six, Six => Seven, Seven => Eight, Eight => Nine,
      Nine  => Ten, Ten => Jack , Jack  => Queen, Queen => King, 
      King  => Ace
    }
    
    # Helper for Rank#previous_rank and Rank#previous?
    PREVIOUS_RANK = {  
      Ace   => King , Two => Ace , Three => Two  , Four => Three, 
      Five  => Four , Six => Five, Seven => Six  , Eight => Seven,
      Nine  => Eight, Ten => Nine, Jack  => Ten  , Queen => King, 
      King  => Ace 
    }
    
    # Generate ranks by value from the ranks
    RANKS_BY_VALUE = RANKS.inject({}) do |hash, rank| 
                      hash[rank.value.to_i] = rank  
                      hash
                     end
                     
    # Add the ace at value 1 too, for convenience.
    RANKS_BY_VALUE[1] = Ace
    
    # Generate ranks by symbol from the ranks
    RANKS_BY_SYMBOL = RANKS.inject({}) do |hash, rank| 
                      hash[rank.symbol.to_s] = rank  
                      hash
                    end
    # Add the 10 at symbol '10' too, for convenience.
    RANKS_BY_SYMBOL['10'] = Ten
                    
    
    # Generate ranks by name from the ranks
    RANKS_BY_NAME = RANKS.inject({}) do |hash, rank| 
                      hash[rank.name.to_s] = rank  
                      hash
                     end
                      
    # Returns the rank that has this given name, or nil if no such rank
    def self.for_name(name)
      return RANKS_BY_NAME[name.to_s]
    end
          
    # Returns the rank that has this value, or nil if no such rank
    def self.for_value(value)
      return RANKS_BY_VALUE[value]
    end
    
    # Returns the rank that has this symbol, or nil if no such rank
    def self.for_symbol(symbol)
      return RANKS_BY_SYMBOL[symbol.to_s]
    end
    
    # Transforms this name, symbol, value or Rank to a Rank
    # Returns nil if this was not possible
    def self.to_rank(r)
      # return r itself if it's allready a rank 
      return r if r.is_a? Rank
      # Try to look up the rank in several ways and return it
      rank   = Rank.for_value(r) 
      rank ||= Rank.for_name(r)
      rank ||= Rank.for_symbol(r)
      return rank
    end


  end
  
  # The suit of a card. It was not in the specs, but it's 
  # cleaner to define a spearate class than to use a string or such.
  class Suit
    
    # Long name of the suit
    attr_reader :name
    # Short, symbolic name of the suit (shdc)
    attr_reader :symbol
    # Unicode symbol for the suit
    attr_reader :unicode
    
    # Initializes the rank with it's name, value and symbol.
    # Ranks are immutable.
    def initialize(name, symbol, unicode) 
      @name     = name.to_s
      @unicode  = unicode.to_s
      @symbol   = symbol.to_s
    end
    
    
    # Converts the rank to a String representation
    def to_s
      if SUIT_UNICODE_OK 
        return self.unicode
      else
        return self.symbol
      end  
    end
    
    # Inspect the rank
    def inspect
      return "<Suit: #@name #@unicode #@symbol>"
    end
    
    # Compares two suits. Suits in Poker are not ranked, so there is no <=>
    # comparator. 
    def ==(other)
      self.symbol == other.symbol 
    end
    
    # The suits
    Hearts    = Suit.new(:Hearts  , :h, '♥')
    Spades    = Suit.new(:Spades  , :s, '♠')
    Diamonds  = Suit.new(:Diamonds, :d, '♦')
    Clubs     = Suit.new(:Clubs   , :c, '♣')
    
    # All suits together    
    SUITS = [ Hearts, Spades, Diamonds, Clubs]
    
    # Generate suits by value from the suits
    SUITS_BY_UNICODE = SUITS.inject({}) do |hash, suit| 
                        hash[suit.unicode] = suit  
                        hash
                      end
    
    # Generate suits by symbol from the ranks
    SUITS_BY_SYMBOL = SUITS.inject({}) do |hash, suit| 
                        hash[suit.symbol] = suit  
                        hash
                      end
        
    # Generate suits by name from the ranks
    SUITS_BY_NAME = SUITS.inject({}) do |hash, suit| 
                        hash[suit.name] = suit  
                        hash
                    end

    # Returns the suit that has this unicode, or nil if no such rank
    def self.for_unicode(unicode)
      return SUITS_BY_UNICODE[unicode.to_s]
    end
          
    # Returns the suit that has this name, or nil if no such suit
    def self.for_name(name)
      return SUITS_BY_NAME[name.to_s]
    end
    
    # Returns the suit that has this symbol, or nil if no such suit
    def self.for_symbol(symbol)
      return SUITS_BY_SYMBOL[symbol.to_s]
    end
    
    # Transforms this name, symbol, unicode symbol or suit to a suit
    # Returns nil if this was not possible
    def self.to_suit(s)
      # return S itself if it's allready a suit 
      return s if s.is_a? Suit
      # Try to look up the suit in several ways and return it 
      suit   = Suit.for_name(s)
      suit ||= Suit.for_symbol(s)
      suit ||= Suit.for_unicode(s)
      return suit
    end
    
  end
  
  
  
  class Card
    include Comparable
    
    attr_reader :suit
    attr_reader :rank
    
    # Constants as per the specs. 
    # The specs said that Ace = 1, but it's better to set it at 14, 
    # as in poker, it's value is higher than than of a King.
    # Also, it's better not to use these constants, bu the ones
    # specified in Rank and Suit
    Jack  = 11
    Queen = 12
    King  = 13
    Ace   = 1
    
    # Initializes the card from a suit name and a rank value  
    def initialize(suitname, rankvalue)
      @suit = Suit.to_suit(suitname)
      @rank = Rank.to_rank(rankvalue)
      raise "Suit #{suitname}  not valid!" unless @suit
      raise "Rank #{rankvalue} not valid!" unless @rank
    end
    
    # Compares cards by their rank 
    def <=>(other)
      self.rank <=> other.rank
    end
    
    # Returns true if the rank of this card is equal to that of the other card
    # This takes wildcards into consideration. If either self or other 
    # is a wildcard, this will always retuun true  
    def same_rank?(other)
      if self.wild? || other.wild?
        return true  
      end
      self.rank == other.rank
    end
    
    # Returns true if the suit of this card is equal to that of the other card
    # This takes wildcards into consideration. If either self or other 
    # is a wildcard, this will always retuun true  
    def same_suit?(other)
      if self.wild? || other.wild?
        return true  
      end
      self.suit == other.suit
    end
    
    # Returns true if the other card is the same as self.
    # Does not take wildcards into consideration
    def same(other) 
      self.suit == other.suit && self.rank == other.rank
    end
    
    # Returns true if other is has a rank one higher than self.
    # This takes wildcards into consideration. If either self or other 
    # is a wildcard, this will always return true  
    def next_rank?(other)
      if self.wild? || other.wild?
        return true  
      end
      self.rank.next?(other.rank)
    end
  
    # Returns true if other is has a rank one lower than self.
    # This takes wildcards into consideration. If either self or other 
    # is a wildcard, this will always return true
    def previous_rank?(other)
      if self.wild? || other.wild?
        return true  
      end
      self.rank.previous?(other.rank)
    end
    
    
    # Makes a string representation of the card
    def to_s
      return self.suit.to_s + self.rank.to_s
    end
    
    # useful for debugging
    def inspect
      "<Card #{@suit} #{@rank}>"
    end
    
    
    # Returns a deep copy of the card
    def dup
      return Card.new(self.suit, self.rank)
    end
    
    # Returns true if the card is a wildcard, false if not.
    def wild?
      return Wildcards.in?(self)
    end
    
    # Transforms a string representation such as d5 or ♥K ro a Card
    # The rank must come first.
    # Will raise an exception if no card could be created 
    def self.to_card(str)
      parts     = str.scan(/./u)
      suitname  = parts[0]            
      rankname  = parts[1] 
      rankname << parts[2] if parts[2]  # could be 2 characters
      return Card.new(suitname, rankname)
    end
    
  end
  
  # A deck of cards 
  class Deck
    # Generates a new 52 deck of cards, in sorted order per suit  
    def initialize()
      @cards = []
      for suit in Suit::SUITS do
        for rank in Rank::RANKS do
          @cards << Card.new(suit, rank)
        end
      end
    end
    
    # string representation of the deck. Prints 4 lines of 13 columns 
    # for a full deck 
    def to_s
      result = ""
      count  = 0
      for card in @cards
        result << "#{card} "
        count += 1
        if count > 12 
          count = 0
          result << "\n"
        end
      end 
      return result
    end
    
    # Shuffles the deck 
    def shuffle!
      size = @cards.size
      @cards.size.times do 
	k1    = rand(size)
	k2    = rand(size)
	card1 = @cards[k1] 
	card2 = @cards[k2]	
	@cards[k1] = card2
	@cards[k2] = card1
      end
      # @cards = @cards.shuffle
    end
    
    # Deals the desired amount of cards from the deck, removing them from it
    # This amount defautls to 1
    # Returns nil if there aren not enough cards available
    def deal!(amount = 1)
      # Return nil if too many cards requested.
      return nil if amount > @cards.size
      # Returns one card if one is requested
      return @cards.shift if amount == 1
      # Returns an array of cards if several are requested. 
      return @cards.shift(amount)
    end

  end

  
  # The Wildcards class defines which cards are wild 
  class Wildcards
    
    # defines which cards are wild. 
    # Removes any previously existing wildcards
    def self.wild(*cards)
      @wildcards = []
      cards.to_a.flatten.each { |card| self.add(card) } 
    end
    
    # adds a single card to the wild cards    
    def self.add(card)
      return unless card.is_a? Card
      # only allow cards to be added
      @wildcards << card
    end
     
    # Returns true if the card is a wildcard, false if not 
    def self.in?(card)
      @wildcards.each do | wildcard |
        return true if wildcard == card
      end
      return false
    end
  end
  
  
  
  # A Hand is a collection of cards
  class Hand 
    attr_reader :cards
    
    # Creates a new hand of cards
    def initialize(*firstcards)
      @cards = []
      # We have to use to_a and flatten to be sure that several 
      # ways of constructing a hand will work
      # As a bonus, nil.to_a is []
      # We call card.add to be sure only real cards can be added
      firstcards.to_a.flatten.each { |card| self.add(card) }
    end
    
    # Adds a Card to the deck. Does nothing if the object added in not a Card.
    def add(card)
      return unless card.is_a? Card
      # only allow cards to be added
      @cards << card
    end 
    
    # Iterates over the deck
    def each()      
      @cards.each do |card|
        yield card
      end 
    end
    

    
    # Sorts the hand by ascending card value
    def sort(&block)
      if block
        sorted = self.cards.sort(&block) 
        return Hand.new(sorted)
      else 	
        sorted = quicksort(@cards) # self.cards.sort
        return Hand.new(sorted)
      end
    end
    
    # Creates a deep copy of the hand, cards included
    def dup()
      newcards = []
      self.each { |card| newcards << card.dup }
      return Hand.new(newcards)
    end
    
    # Creates a string representation of the hand 
    def to_s
      result = ""
      self.each { |card | result << "#{card} " } 
      return result
    end
    
    # Creates a hand from a space-separated string
    # containing card abbreviations such as c5 or ♦4
    def self.to_hand(str)
      hand = Hand.new
      cardnames = str.split(' ')
      for name in cardnames do
        card = Card.to_card(name)
        hand.add(card)     
      end
      return hand
    end
    
    # Looks in this hand for cards that have the same Rank as the given card, 
    # and returns them in an array. Returns an empty array if none 
    # were found. This takes wildcards into consideration. 
    def find_same_rank(givencard)
      result = []
      for card in @cards do
        result << card if card.same_rank?(givencard)
      end
      return result
    end
    
    # Looks in this hand for cards that have the same Rank as the given card, 
    # and returns them in an array. Returns an empty array if none 
    # were found. This excludes wildcards 
    def find_same_rank_not_wild(givencard)
      result = []
      for card in @cards do
        if card.same_rank?(givencard) && (!card.wild?)
          result << card
        end   
      end
      return result
    end

    # Returns the first card in the hand that isn't a wild card
    # Returns nil if all cards are wild 
    def first_not_wild
      for card in @cards
        return card unless card.wild?
      end
      return nil
    end
     
    # Returns all cards in the hand that aren't a wild card
    # Returns an empty array if all cards are wild 
    def all_not_wild
      result = []
      for card in @cards
        result << card unless card.wild? 
      end
      return result
    end
    
    FixedSize = 5 
    # Although most of the hand ratings will work with more than five cards
    # I did not test it well enough to allow it.  
    
    # Matched cards returns a hash of cards of matched value, keyed by rank 
    def matched_cards
      result = {}
      for card in @cards do
        if card.wild? ## wild cards belong to all ranks 
          for rank in Rank::RANKS do
            result[rank] ||= []
            result[rank] << card
          end  
        else  
          result[card.rank] ||= []
          result[card.rank] << card
        end  
      end
      return result
    end 
    
    # In 5 card stud poker with wildcards, five of a kind is the 
    # highest possible score
    # Returns true if the hand is a five of a kind or better, false if not.
    def five_of_a_kind?
      # Get all cards of the same rank as the first one, and 
      # checks if there are five of them.
      # However, we have to skip any wildcards, since they're always true
      given = self.first_not_wild
      # If all cards are wild, it's a five of a kind
      # This could only happen if there are 5 or more wild cards
      # defined
      return true unless given  
      same = find_same_rank(given)
      # It has to be >= in case the hand has 6 or more cards
      # and some wildcards in them.
      # In the face of wildcards, it possibe to have any amount of "same" 
      # cards in a hand
      return same.size >= 5 
    end
     
    # Returns true if the hand is a four of a kind or better, false if not.
    def four_of_a_kind?
      # Go over all the cards and see if we have four of them 
      # However, we have to skip any wildcards, since they're always the same
      givens = self.all_not_wild
      return true unless givens.size > 0
      # If all cards are wild, it's also a four of a kind 
      for given in givens do         
        same = find_same_rank(given)
        # >= because a five of a kind is also a four of a kind
        return true if same.size >= 4
      end
      return false
    end
    
    # Returns true if the hand is a three of a kind or better, false if not.
    def three_of_a_kind?
      # Go over all the cards and see if we have three of them 
      # However, we have to skip any wildcards, since they're always the same
      givens = self.all_not_wild
      return true unless givens.size > 0
      # If all cards are wild, it's also a three of a kind 
      for given in givens do         
        same = find_same_rank(given)
        # >= because a four of a kind is also a three of a kind
        return true if same.size >= 3
      end
      return false
    end
    
    # Returns true if the hand is a pair or better, false if not.
    def pair?
      # Go over all the cards and see if we have two of them 
      # However, we have to skip any wildcards, since they're always the same
      givens = self.all_not_wild
      return true unless givens.size > 0
      # If all cards are wild, it's also a pair  
      for given in givens do         
        same = find_same_rank(given)
        # >= because a three of a kind is also a pair
        return true if same.size >= 2
      end
      return false
    end
         
    # Returns true if the hand is a two pairs or better, false if not.
    def two_pair?
      # pairs that we found 
      found_pairs = []
      # Cards already used in a pair, hence cannot be used again 
      used        = []
      # Go over all the cards and see if we have two of them 
      # However, we have to skip any wildcards, since they're always the same
      givens = self.all_not_wild
      return true unless givens.size > 0
      # If all cards are wild, it's also a pair  
      for given in givens do         
        for card in @cards do
          # Skip used cards
          next if used.member?(card) || used.member?(given)
          # Don't compare card with itself
          next if card.same(given)  
          if card.same_rank?(given)  
            found_pairs << [card, given]
            used        << card
            used        << given
          end
        end
      end
      return found_pairs.size >= 2
    end
    
    # Returns true if the hand is a straight of 5 cards, false if not.
    def straight?
      sorted = @cards.sort # sorted by value
      result = false
      # First try for the normal case. 
      count  = 1
      old    = sorted.shift
      # Go over the cards and see if the next_rank chain can be maintained.  
      for card in sorted.each do
        break if !(old.next_rank?(card))
        count += 1 
        old    = card
      end
      return true if count == 5  
      # But what if the top card is an ace?
      # Try again by using that first   
      sorted = @cards.sort # sorted by value
      result = false
      # First try for the normal case. 
      count  = 1
      old    = sorted.pop
      # Go over the cards and see if the next_rank chain can be maintained.  
      for card in sorted.each do
        break if !(old.next_rank?(card))
        count += 1 
        old    = card
      end
      # If we have 5 cards that follow each other it's a straight.
      return true if count == 5
      return false
    end
     
    # Returns a hash of cards with matching suits, keyeb by suit 
    def matched_suits
      per_suit = {}
      # Count how many there are of each suit 
      aid = @cards.each do |card| 
        # Wildcards belong to all suits 
        if card.wild?
          for suit in Suit::SUITS
            per_suit[suit] ||= 0
            per_suit[suit]  += 1
          end
        else
          per_suit[card.suit] ||= 0
          per_suit[card.suit]  += 1
        end
      end
      return per_suit
    end
 
     
    # Returns true if the hand is a flush of 5 cards.
    def flush?
      per_suit = matched_suits
      for suit, count in per_suit do
        return true if count >= 5
      end      
      return false 
    end 
    
    # Returns true if the hand is a straight flush 
    def straight_flush?()
      return self.straight? && self.flush? 
    end
    
    # Returns true if this hand is a full house, false if not
    def full_house?
      matched     = self.matched_cards
      found_pair  = false
      found_three = false
      for rank, matches in matched do
        found_pair  = true if matches.count == 2
        found_three = true if matches.count == 3
      end
      return found_pair && found_three    
    end
    
    
    
    
    # Score based on combination only, no tiebreaker 
    def combination_score
      if five_of_a_kind?
        return 9000 
      elsif straight_flush? 
        return 8000
      elsif four_of_a_kind? 
        return 7000
      elsif full_house? 
        return 6000
      elsif flush?  
        return 5000
      elsif straight? 
        return 4000
      elsif three_of_a_kind? 
        return 3000
      elsif two_pair? 
        return 2000
      elsif pair? 
        return 1000
      else
        return 0
      end
    end
    
    # Tiebreaker returns an array fo the cards whose value breaks the tie
    def tie_breaker_cards
      matched = self.matched_cards
      sorted  = @cards.sort.reverse
      # sorted so the card with highest value is first 
      if five_of_a_kind? 
        # All cards break the tie
        return sorted 
      elsif flush?
        # All cards break the tie
        return sorted 
      elsif four_of_a_kind?
        four = matched.find{ |rank, cards| cards.size == 4}
        # quads break the tie first, then the other card 
        return four + [(sorted - four).first]          
      elsif full_house?
        three = matched.find{ |rank, cards| cards.size == 3}
        two   = matched.find{ |rank, cards| cards.size == 2}
        return three + two
      elsif straight?
        # Special case for ace, 2, 3, 4 ,5  straight, which sorts as
        # 2,3,4,5,A  
        if sorted.first.rank == Rank::Ace && sorted.last.rank == Rank::Two  
          ace = sorted.pop 
          sorted.unshift(ace) # put ace at the back
          return [ sorted.first ] # should be the 5 now 
        else
          return [ sorted.first ]    
        end
      elsif three_of_a_kind?
        three = matched.find{ |rank, cards| cards.size == 3}          
        return three + (sorted - three).first(2)
      elsif two_pair?
        pairs    = [] 
        matched.each{ |rank, cards| pairs << cards if cards.size == 2 }  
        two_pair = pairs[0] + pairs[1]
        two_pair + [(sorted - two_pair).first]
      elsif pair?
        two  = matched.find{ |rank, cards| cards.size == 2}          
        two + (sorted - two).first(3)
      else
        sorted.first(5)
      end
    end
     
    # Breaks the tie with the other hand
    # Return -1 if less, 1 if more, and 0 if equal
    def break_tie(other_hand) 
      mycards = self.tie_breaker_cards
      othertb = other_hand.tie_breaker_cards
      stop    = mycards.size
      for i in (0...stop) do
        res = mycards[i] <=> othertb[i]
        # Tie is broken
        # Note that wildcards will retain their own value
        # This means that, for example if deuces are wild,
        # a K K K three of a kind will beat a K K 2 three of a kind 
        return res if res != 0  
      end  
      # If we came here it's a split pot
      return 0
    end
    
    # Compares two hands by their value
    def <=>(other) 
      res = (self.combination_score <=> other.combination_score)
      # First try by combination
      return res if res != 0
      # Otherwise break the tie 
      return break_tie(other)
    end
  end 
end

