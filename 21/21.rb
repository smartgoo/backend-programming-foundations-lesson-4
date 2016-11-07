require 'pry'

VALUES = { '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7,
           '8' => 8, '9' => 9, '10' => 10, 'Jack' => 10, 'Queen' => 10,
           'King' => 10, 'Ace' => 11 }.freeze
MAX_SCORE = 21
DEALER_SCORE = 17

def create_deck
  deck = { 'Diamonds' => {}, 'Hearts' => {}, 'Spades' => {}, 'Clubs' => {} }
  deck.each do |suit, _|
    (2..14).each do |card|
      deck[suit][card.to_s] = {}
      deck[suit][card.to_s][:available] = "y"
      if card < 11
        deck[suit][card.to_s][:card_name] = card.to_s
      elsif card == 11
        deck[suit][card.to_s][:card_name] = "Jack"
      elsif card == 12
        deck[suit][card.to_s][:card_name] = "Queen"
      elsif card == 13
        deck[suit][card.to_s][:card_name] = "King"
      elsif card == 14
        deck[suit][card.to_s][:card_name] = "Ace"
      end
    end
  end
  deck
end

def prompt(message)
  puts "=> #{message}"
end

def card_available?(cards, st, crd)
  if cards[st][crd][:available] == "y"
    cards[st][crd][:available] = "n"
    cards[st][crd][:card_name]
  end
end

def bust?(dealt_crds, indx)
  calc_score_aces(dealt_crds, indx) <= MAX_SCORE
end

def calculate_score(arr)
  score_arr = []
  arr.each do |v|
    if VALUES.keys.include?(v)
      score_arr.push(VALUES[v])
    end
  end

  score = 0
  score_arr.each { |v| score += v }
  score
end

def calc_score_aces(arr, indx)
  temp_ace_sum = 0
  total_non_ace_score = calculate_score(arr[indx].select { |val| val != 'Ace' })
  total_ace_score = calculate_score(arr[indx].select { |val| val == 'Ace' })

  if total_non_ace_score + total_ace_score <= MAX_SCORE
    return total_score = total_non_ace_score + total_ace_score
  else
    ace_score_arr = []
    (0..arr[indx].select { |val| val == 'Ace' }.count - 1).each { |num| ace_score_arr[num] = 11 }
    ace_score_arr.each_index do |v|
      ace_score_arr[v] -= 10
      temp_ace_sum = 0
      ace_score_arr.each { |a| temp_ace_sum += a }
      if temp_ace_sum + total_non_ace_score <= MAX_SCORE
        return total_score = temp_ace_sum + total_non_ace_score
      end
    end
  end
  total_score = total_ace_score + total_non_ace_score
end

def deal_card(cards)
  loop do
    suit = cards.keys.sample
    card = cards[suit].keys.sample
    crd_nm_avail = card_available?(cards, suit, card)
    if crd_nm_avail
      return crd_nm_avail
    end
  end
end

def determine_winner(crds, dealer, player)
  if player == true
    "Dealer"
  elsif dealer == true
    "Player"
  elsif calc_score_aces(crds, 0) >= calc_score_aces(crds, 1)
    "Dealer"
  else
    "Player"
  end
end

def initial_deal(cards)
  dealt = [[], []]
  dealt[0][0] = deal_card(cards)
  dealt[1][0] = deal_card(cards)
  dealt[0][1] = deal_card(cards)
  dealt[1][1] = deal_card(cards)
  dealt
end

def display_cards(arr, player, computer) # need to clean up this method
  system 'clear'
  puts "Player: #{player} Dealer: #{computer}", ""
  puts "Dealer: Hidden Card, #{arr[0][(1..52)].join(', ')}"
  puts "Player: #{arr[1].join(', ')}"
  puts "---------------------------------------------------", ""
end

def busted_text(who)
  if who == 'Player'
    prompt "You busted!"
  else
    prompt "Dealer busted!"
  end
end

def approp_answer(pos_arr, neg_arr)
  loop do
    answer = gets.chomp.downcase
    if pos_arr.include?(answer)
      return 'positive'
    elsif neg_arr.include?(answer)
      return 'negative'
    else
      prompt "Please enter a valid choice"
    end
  end
end

player_score = 0
computer_score = 0

loop do
  deck = create_deck
  dealt_cards = initial_deal(deck)
  display_cards(dealt_cards, player_score, computer_score)
  player_busted = false
  dealer_busted = false

  loop do
    if bust?(dealt_cards, 1)
      prompt "Hit or stay?"
      break if approp_answer(['hit'], ['stay']) == 'negative'
      dealt_cards[1].push(deal_card(deck))
      display_cards(dealt_cards, player_score, computer_score)
    else
      busted_text('Player')
      player_busted = true
      break
    end
  end

  if player_busted == false
    loop do
      if bust?(dealt_cards, 0)
        if calc_score_aces(dealt_cards, 0) < DEALER_SCORE
          dealt_cards[0].push(deal_card(deck))
          display_cards(dealt_cards, player_score, computer_score)
          prompt "Dealer was under #{DEALER_SCORE} and drew a card"
        else
          prompt "Dealer stays"
          break
        end
      else
        busted_text('Dealer')
        dealer_busted = true
        break
      end
    end
  end

  if determine_winner(dealt_cards, dealer_busted, player_busted) == 'Dealer'
    prompt "Dealer wins with #{calc_score_aces(dealt_cards, 0)}!"
    computer_score += 1
  else
    prompt "Player wins with #{calc_score_aces(dealt_cards, 1)}!"
    player_score += 1
  end

  prompt "Dealers hidden card: #{dealt_cards[0][0]}"

  prompt "Press enter when ready to move on to the next round"
  gets

  if player_score == 5
    prompt "Player won the game!"
  elsif computer_score == 5
    prompt "Dealer won the game!"
  end
end

prompt "Thanks for playing!"
