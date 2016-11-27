# OLD

require 'pry'

VALUES = { "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7,
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

def add_to_glog(str, glog)
  glog.push(str)
end

def print_glog(glog)
  puts glog.join("\n")
end

def prompt(message, glog = [])
  add_to_glog("=> #{message}", glog)
  puts "=> #{message}"
end

def card_available?(cards, st, crd)
  if cards[st][crd][:available] == "y"
    cards[st][crd][:available] = "n"
    cards[st][crd][:card_name]
  end
end

def bust?(dealt_crds)
  calc_ttl_score(dealt_crds) <= MAX_SCORE
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

def decide_each_ace(arr, non_ace_score)
  ace_score_arr = []
  length = arr.select { |val| val == 'Ace' }.count - 1
  (0..length).each { |num| ace_score_arr[num] = 11 }
  ace_score_arr.each_index do |i|
    ace_score_arr[i] -= 10
    temp_ace_sum = 0
    ace_score_arr.each { |a| temp_ace_sum += a }
    if temp_ace_sum + non_ace_score <= MAX_SCORE
      return temp_ace_sum + non_ace_score
    end
  end
  nil
end

def calc_ttl_score(arr)
  total_non_ace_score = calculate_score(arr.select { |val| val != 'Ace' })
  total_ace_score = calculate_score(arr.select { |val| val == 'Ace' })

  if total_non_ace_score + total_ace_score <= MAX_SCORE
    return total_non_ace_score + total_ace_score
  elsif !decide_each_ace(arr, total_non_ace_score).nil?
    return decide_each_ace(arr, total_non_ace_score)
  end
  total_ace_score + total_non_ace_score
end

def deal_card(cards)
  loop do
    suit = cards.keys.sample
    card = cards[suit].keys.sample
    crd_nm_avail = card_available?(cards, suit, card)
    if crd_nm_avail
      return [crd_nm_avail, suit]
    end
  end
end

def determine_winner(crds, dealer, player)
  if player == true
    "Dealer"
  elsif dealer == true
    "Player"
  elsif calc_ttl_score(rmv_suit(crds, 0)) >= calc_ttl_score(rmv_suit(crds, 1))
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

def display_cards(arr, player, computer, glog, game_state = 'ongoing')
  system 'clear'
  puts "Player: #{player} Dealer: #{computer}", "", "Dealer:"
  if game_state == 'ongoing'
    puts " - Hidden Card"
    arr[0].each_index do |i|
      i >= 1 ? puts(" - #{arr[0][i].join(' (')}" + ')') : nil
    end
  else
    arr[0].each { |v| puts " - #{v.join(' (')}" + ')' }
  end

  puts "", "Player"
  arr[1].each { |v| puts " - #{v.join(' (')}" + ')' }
  puts "---------------------------------------------------", ""

  print_glog(glog)
end

def busted_text(who, glog)
  if who == 'Player'
    prompt("You busted!", glog)
  else
    prompt("Dealer busted!", glog)
  end
end

def rmv_suit(arr, indx)
  crds = []
  arr[indx].each_index do |i|
    arr[indx][i].each_index do |i2|
      if i2.zero?
        crds.push arr[indx][i][i2]
      end
    end
  end
  crds
end

def approp_answer?(pos_arr, neg_arr, glog)
  loop do
    answer = gets.chomp.downcase
    if pos_arr.include?(answer)
      add_to_glog(answer, glog)
      return 'pos'
    elsif neg_arr.include?(answer)
      add_to_glog(answer, glog)
      return 'neg'
    else
      add_to_glog(answer, glog)
      prompt("Please enter a valid choice", glog)
    end
  end
end

player_score = 0
computer_score = 0

loop do
  game_log = []
  deck = create_deck
  dealt_cards = initial_deal(deck)
  display_cards(dealt_cards, player_score, computer_score, game_log)
  player_busted = false
  dealer_busted = false

  loop do
    if bust?(rmv_suit(dealt_cards, 1))
      prompt("(h)it or (s)tay?", game_log)
      break if approp_answer?(['hit', 'h'], ['stay', 's'], game_log) == 'neg'
      dealt_cards[1].push(deal_card(deck))
      display_cards(dealt_cards, player_score, computer_score, game_log)
    else
      busted_text('Player', game_log)
      display_cards(dealt_cards, player_score, computer_score, game_log)
      player_busted = true
      break
    end
  end

  unless player_busted == true # this will not be executed if the player busts
    loop do
      if bust?(rmv_suit(dealt_cards, 0))
        if calc_ttl_score(rmv_suit(dealt_cards, 0)) < DEALER_SCORE
          dealt_cards[0].push(deal_card(deck))
          display_cards(dealt_cards, player_score, computer_score, game_log)
          prompt("Dealer was under #{DEALER_SCORE} and drew a card", game_log)
        else
          prompt("Dealer stays", game_log)
          break
        end
      else
        busted_text('Dealer', game_log)
        display_cards(dealt_cards, player_score, computer_score, game_log)
        dealer_busted = true
        break
      end
    end
  end

  if determine_winner(dealt_cards, dealer_busted, player_busted) == 'Dealer'
    computer_cards = rmv_suit(dealt_cards, 0)
    prompt("Dealer wins with #{calc_ttl_score(computer_cards)}!", game_log)
    computer_score += 1
  else
    player_cards = rmv_suit(dealt_cards, 1)
    prompt("Player wins with #{calc_ttl_score(player_cards)}!", game_log)
    player_score += 1
  end

  display_cards(dealt_cards, player_score, computer_score, game_log, 'done')

  if player_score == 5
    prompt("Player won the game!", game_log)
    break
  elsif computer_score == 5
    prompt("Dealer won the game!", game_log)
    break
  end

  prompt("(r)eady for the next round? (you can also (q)uit here).", game_log)
  break if approp_answer?(['ready', 'r'], ['quit', 'q'], game_log) == 'neg'
end

prompt("Thanks for playing!")
