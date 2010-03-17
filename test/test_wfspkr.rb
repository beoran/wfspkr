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
# Include directory is 2 up from here and lib 
require "wfspkr"


# Built in tests
if __FILE__ == $0 && Wfspkr::SHOW_BUILTIN_TESTS
  
  include Wfspkr
  # Wfspkr::SUIT_UNICODE_OK = true (default) 
  # Use the unicode symbols '♠♣♦♥' for nicer display
  p Rank::Ace
  p Rank::RANKS
  p Suit::SUITS
  puts Rank::Ace.to_s
  puts Rank.for_value(14).to_s
  sa = Card.new(:Spades, :Ace)
  c2 = Card.new(:Clubs, 2) 
  p sa 
  p c2
  puts sa.to_s
  p sa.dup
  # make all twos wild
  Wildcards.wild(Card.to_card('s2'), Card.to_card('c2'), 
                 Card.to_card('d2'), Card.to_card('h2'))
  p c2.wild?
  p sa.wild?
  d = Deck.new
  puts d.to_s
  d.shuffle!
  puts d.to_s
  h = Hand.new(d.deal!(5))
  puts d.to_s
  h2 = Hand.to_hand('♥2 ♠4 ♣4 ♦4 ♥4')
  puts h.to_s
  puts h.sort.to_s
  p h.five_of_a_kind?
  puts h2.to_s
  p h2.five_of_a_kind?
  p h2.four_of_a_kind?
  # Now, make all sixes wild 
  Wildcards.wild(Card.to_card('s6'), Card.to_card('c6'), 
                 Card.to_card('d6'), Card.to_card('h6'))
  puts h2.to_s
  p h2.five_of_a_kind?
  # should be false now, because no more 2 wildcards
  p h2.four_of_a_kind?
  # should still be true   
  h3 = Hand.to_hand('♥2 ♠4 ♣4 ♦4 ♥3')
  puts h3.to_s
  p h3.three_of_a_kind?
  p h3.four_of_a_kind?
  h4 = Hand.to_hand('♥2 ♠4 ♣4 ♦5 ♥3')
  puts h4.to_s
  p h4.three_of_a_kind?
  p h4.pair?

  h5 = Hand.to_hand('♥2 ♠4 ♣4 ♦5 ♥5')
  puts h5.to_s
  p h5.two_pair?
  p h5.pair?

  h6 = Hand.to_hand('♥2 ♠4 ♣8 ♦5 ♥Q')
  puts h6.to_s
  p h6.two_pair?
  p h6.pair?
  p h6.full_house?
  p h6.straight?
  p h6.flush?

  
  h7 = Hand.to_hand('♥7 ♥8 ♥9 ♥T ♥J')
  puts h7.to_s
  p h7.straight?
  p h7.flush?
  p h7.straight_flush?
  # p h7.matched_cards
   
  h8 = Hand.to_hand('♥2 ♠2 ♣2 ♦Q ♥Q')
  puts h8.to_s
  p h8.two_pair?
  p h8.pair?
  p h8.full_house?
  p h8.four_of_a_kind?
  p h8 <=> h7
  puts "---"
  a = [ h6, h7, h8 ]
  puts a.sort
  
  h9  = Hand.to_hand('♦A ♦2 ♦3 ♦4 ♦5')
  h10 = Hand.to_hand('♥A ♥K ♥Q ♥J ♥10')
  puts [h9, h10].sort
  puts "---"
  h11 = Hand.to_hand('♦10 ♥10 ♦3 ♦5 ♦7')
  h12 = Hand.to_hand('♦K ♥K ♥Q ♥J ♥10')
  h13 = Hand.to_hand('♣K ♠K ♥J ♥J ♥A')
  puts [h11, h12, h13].sort
  puts "---"
  h14 = Hand.to_hand('♦K ♥K ♥Q ♦Q ♥10')
  h15 = Hand.to_hand('♣K ♠K ♣J ♠J ♥A')
  h16 = Hand.to_hand('♣K ♠K ♣J ♠J ♥10')
  puts [h14, h15, h16].sort
  puts "---"  
  h17 = Hand.to_hand('♦K ♥K ♥K ♦Q ♥10')
  h18 = Hand.to_hand('♣K ♠K ♣K ♠J ♥A')  
  puts [h17, h18].sort
  puts "---"
  h19 = Hand.to_hand('♦K ♦J ♦10 ♦8 ♦6')
  h20 = Hand.to_hand('♣K ♣J ♣10 ♣8 ♣A')  
  puts [h19, h20].sort
  puts "---"  
  h21 = Hand.to_hand('♦A ♦K ♦Q ♦J ♦10')
  h22 = Hand.to_hand('♣K ♣Q ♣J ♣10 ♣9')  
  puts [h21, h22].sort
  puts "---"
  
  h23 = Hand.to_hand('♦K ♥K ♣K ♠K ♥6')
  h24 = Hand.to_hand('♦Q ♥Q ♣Q ♠Q ♠6')
  h25 = Hand.to_hand('♦K ♥K ♣K ♠K ♥3')
  h26 = Hand.to_hand('♦Q ♥Q ♣Q ♠Q ♠3')  
  puts [h23, h24, h25, h26].sort  
  puts "---"
  
  h27 = Hand.to_hand('♦K ♥K ♣K ♠A ♥A')
  h28 = Hand.to_hand('♦K ♥K ♣K ♥Q ♠Q')
  puts [h27, h28].sort  
  puts "---"

  h27 = Hand.to_hand('♦K ♥K ♣7 ♠A ♥A')
  h28 = Hand.to_hand('♣K ♠K ♣5 ♥Q ♠Q')
  puts [h27, h28].sort  
  puts "---"


end


