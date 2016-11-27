require 'pry'

SUITS = ['Hearts', 'Spades', 'Diamonds', 'Clubs'].freeze
CARD_VALUES = ['2', '3', '4', '5', '6', '7', '8', '9',
               '10', 'Jack', 'Queen', 'King', 'Ace'].freeze
MAX_SCORE = 21
DEALER_MIN_SCORE = 17

def add_to_game_log(str, game_log)
  game_log.push(str)
end

def prompt(message, game_log = [])
  add_to_game_log("=> #{message}", game_log)
  puts "=> #{message}"
end

def create_deck
  CARD_VALUES.product(SUITS).shuffle
end

def total(cards)
  # remove suit
  values = cards.map { |card| card[0] }

  sum = 0
  values.each do |value|
    if value == 'Ace'
      sum += 11
    elsif value.to_i.zero? && value != '?'
      sum += 10
    elsif value.to_i <= 10
      sum += value.to_i
    end
  end

  values.select { |value| value == 'Ace' }.count.times do
    sum -= 10 if sum > 21
  end

  sum
end

def busted?(hand)
  total(hand) > 21
end

def decide_result(player_hand, dealer_hand)
  if busted?(player_hand)
    :player_busted
  elsif busted?(dealer_hand)
    :dealer_busted
  elsif total(dealer_hand) >= total(player_hand)
    :dealer
  else
    :player
  end
end

def display_result(player_hand, dealer_hand, game_log)
  game_result = decide_result(player_hand, dealer_hand)

  case game_result
  when :player_busted
    prompt("You busted!", game_log)
  when :dealer_busted
    prompt("Dealer busted!", game_log)
  when :dealer
    prompt("Dealer wins!", game_log)
  when :player
    prompt("You win!", game_log)
  end
end

def print_game_log(game_log)
  puts game_log.join("\n")
end

def display_ui(player_hand, dealer_hand, game_log, player_wins, dealer_wins)
  system 'clear'

  puts "Player: #{player_wins} Dealer: #{dealer_wins}"

  puts "", "Player total: #{total(player_hand)}"
  player_hand.each { |value| puts value.join(' (') + ')' }

  puts "", "Dealer total: #{total(dealer_hand)}"
  dealer_hand.each { |value| puts value.join(' (') + ')' }

  puts "_____________________________________________", ""

  print_game_log(game_log)
end

# main game loop
player_wins = 0
dealer_wins = 0

loop do
  # initialize variables
  deck = create_deck
  game_log = []
  player_hand = []
  dealer_hand = []
  dealer_hid = []

  # first deal
  2.times do
    player_hand << deck.pop
    dealer_hand << deck.pop
  end

  dealer_hid = dealer_hand.dup
  dealer_hid[0] = ["?", "?"]

  display_ui(player_hand, dealer_hid, game_log, player_wins, dealer_wins)

  loop do
    # player turn
    loop do
      player_answer = ''
      loop do
        prompt("(H)it or (s)tay?", game_log)
        player_answer = gets.chomp
        add_to_game_log(player_answer, game_log)
        break if player_answer == 'h' || player_answer == 's'
        prompt("Please enter a valid choice", game_log)
      end

      if player_answer == 'h'
        player_hand << deck.pop
        display_ui(player_hand, dealer_hid, game_log, player_wins, dealer_wins)
      end

      break if player_answer == 's' || busted?(player_hand)
    end

    if busted?(player_hand)
      display_result(player_hand, dealer_hand, game_log)
      break
    end

    # dealer turn
    loop do
      if total(dealer_hand) < DEALER_MIN_SCORE
        dealer_hand << deck.pop
        prompt("Dealer was under #{DEALER_MIN_SCORE} and drew a card", game_log)
        display_ui(player_hand, dealer_hid, game_log, player_wins, dealer_wins)
      else
        prompt("Dealer did not draw a card", game_log)
        break
      end
    end

    display_result(player_hand, dealer_hand, game_log)
    break
  end

  # update round wins count
  round_result = decide_result(player_hand, dealer_hand)
  case round_result
  when :dealer
    dealer_wins += 1
  when :player_busted
    dealer_wins += 1
  when :player
    player_wins += 1
  when :dealer_busted
    player_wins += 1
  end

  display_ui(player_hand, dealer_hand, game_log, player_wins, dealer_wins)

  # break if a player wins the game by hitting 5 round wins
  if player_wins == 5
    prompt("Player won the game!", game_log)
    break
  elsif dealer_wins == 5
    prompt("Dealer won the game!", game_log)
    break
  end

  # See if the player is ready to move on to the next round
  player_move_on_answer = nil
  loop do
    prompt("(R)eady to play the next round? (you can also (q)uit)", game_log)
    player_move_on_answer = gets.chomp.downcase
    add_to_game_log(player_move_on_answer, game_log)
    break if player_move_on_answer == 'r' || player_move_on_answer == 'q'
    prompt("Please enter a valid choice", game_log)
  end
  break if player_move_on_answer == 'q'
end

prompt("Thanks for playing!")
