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
# This file contains a suite of test casess for wfspkr
$: << File.join('..','lib')
# Include directory is 2 uputs from here and lib 
require "wfspkr"


# Built in tests
if __FILE__ == $0 
  
  include Wfspkr
  # Use the unicode symbols '♠♣♦♥' for nicer display
  puts Rank::Ace
  puts Rank::RANKS
  puts Suit::SUITS
  puts Rank::Ace.to_s
  puts Rank.for_value(14).to_s
  sa = Card.new(:Spades, Card::Ace)
  c2 = Card.new(:Clubs, 2) 
  puts sa 
  puts c2
  puts sa.to_s
  puts sa.dup
  # make all twos wild
  Wildcards.wild(Card.to_card('c2'), 
		 Card.to_card('s2'), 
		 
                 Card.to_card('d2'), 
		 Card.to_card('h2'))
  puts c2.wild?
  puts sa.wild?
  d = Deck.new
  puts d.to_s
  d.shuffle!
  puts d.to_s
  h = Hand.new(d.deal!(5))
  puts d.to_s
  h2 = Hand.to_hand('♥2 ♠4 ♣4 ♦4 ♥4')
  puts h.to_s
  puts h.sort.to_s
  puts h.five_of_a_kind?
  puts h2.to_s
  puts h2.five_of_a_kind?
  puts h2.four_of_a_kind?
  # Now, make all sixes wild 
  Wildcards.wild(Card.to_card('s6'), Card.to_card('c6'), 
                 Card.to_card('d6'), Card.to_card('h6'))
  puts h2.to_s
  puts h2.five_of_a_kind?
  # Should be false now, because no more 2 wildcards
  puts h2.four_of_a_kind?
  # Should still be true   
  
  # To_hand generats a hand based upon a short descrption.
  h3 = Hand.to_hand('♥2 ♠4 ♣4 ♦4 ♥3')  
  puts h3.to_s
  # Should be true for three of a kind and false for four of a kind
  puts h3.three_of_a_kind?
  puts h3.four_of_a_kind?
  
  h4 = Hand.to_hand('♥2 ♠4 ♣4 ♦5 ♥3')
  puts h4.to_s
  # Should be true for pair of a kind and false for three of a kind
  puts h4.three_of_a_kind?
  puts h4.pair?
  
  h5 = Hand.to_hand('♥2 ♠4 ♣4 ♦5 ♥5')
  # Should be true for both pair and two pair
  puts h5.to_s
  puts h5.two_pair?
  puts h5.pair?

  
  h6 = Hand.to_hand('♥2 ♠4 ♣8 ♦5 ♥Q')  
  puts h6.to_s
  # Should be false for all cases
  puts h6.two_pair?
  puts h6.pair?
  puts h6.full_house?
  puts h6.straight?
  puts h6.flush?

  
  h7 = Hand.to_hand('♥7 ♥8 ♥9 ♥T ♥J')
  puts h7.to_s
  # Should be true for all three straight, flush and straight flush
  puts h7.straight?
  puts h7.flush?
  puts h7.straight_flush?
  # puts h7.matched_cards
   
  h8 = Hand.to_hand('♥2 ♠2 ♣2 ♦Q ♥Q')
  puts h8.to_s
  # Should be true for two pairn, pair, full house, but false for 
  # four of a kind
  puts h8.two_pair?
  puts h8.pair?
  puts h8.full_house?
  puts h8.four_of_a_kind?
  puts h8 <=> h7
  puts "---"
  a = [ h6, h7, h8 ]
  # Hand valuing and sorting tests. 
  puts a.sort
  puts "---"
  # Straight flushes, low and high
  h9  = Hand.to_hand('♦A ♦2 ♦3 ♦4 ♦5')
  h10 = Hand.to_hand('♥A ♥K ♥Q ♥J ♥10')
  puts [h9, h10].sort
  puts "---"
  # pairs and two pairs
  h11 = Hand.to_hand('♦10 ♥10 ♦3 ♦5 ♦7')
  h12 = Hand.to_hand('♦K ♥K ♥Q ♥J ♥10')
  h13 = Hand.to_hand('♣K ♠K ♥J ♥J ♥A')
  puts [h11, h12, h13].sort
  puts "---"
  # Two pairs
  h14 = Hand.to_hand('♦K ♥K ♥Q ♦Q ♥10')
  h15 = Hand.to_hand('♣K ♠K ♣J ♠J ♥A')
  h16 = Hand.to_hand('♣K ♠K ♣J ♠J ♥10')
  puts [h14, h15, h16].sort
  puts "---" 
  # Three of a kinds 
  h17 = Hand.to_hand('♦K ♥K ♥K ♦Q ♥10')
  h18 = Hand.to_hand('♣K ♠K ♣K ♠J ♥A')  
  puts [h17, h18].sort
  puts "---"
  # Flushes
  h19 = Hand.to_hand('♦K ♦J ♦10 ♦8 ♦6')
  h20 = Hand.to_hand('♣K ♣J ♣10 ♣8 ♣A')  
  puts [h19, h20].sort
  puts "---"
  # Straight flushes
  h21 = Hand.to_hand('♦A ♦K ♦Q ♦J ♦10')
  h22 = Hand.to_hand('♣K ♣Q ♣J ♣10 ♣9')  
  puts [h21, h22].sort
  puts "---"
  # Four of a kind with and without wildcards
  h23 = Hand.to_hand('♦K ♥K ♣K ♠K ♥6')
  h24 = Hand.to_hand('♦Q ♥Q ♣Q ♠Q ♠6')
  h25 = Hand.to_hand('♦K ♥K ♣K ♠K ♥3')
  h26 = Hand.to_hand('♦Q ♥Q ♣Q ♠Q ♠3')  
  puts [h23, h24, h25, h26].sort  
  puts "---"
  # Full houses
  h27 = Hand.to_hand('♦K ♥K ♣K ♠A ♥A')
  h28 = Hand.to_hand('♦K ♥K ♣K ♥Q ♠Q')
  puts [h27, h28].sort  
  puts "---"
  # Two pairs again
  h27 = Hand.to_hand('♦K ♥K ♣7 ♠A ♥A').sort
  h28 = Hand.to_hand('♣K ♠K ♣5 ♥Q ♠Q').sort
  puts [h27, h28].sort  
  puts "---"
  
  puts Wfspkr::Rank::RANKS

end


