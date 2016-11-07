require 'pry'

INITIAL_MARKER = ' '
PLAYER_MARKER = 'O'
COMPUTER_MARKER = 'X'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                [[1, 5, 9], [3, 5, 7]]

# rubocop:disable Metrics/MethodLength
def display_board(squares, user, comp)
  system 'clear'
  puts "User: #{user}. Computer: #{comp}"
  puts "     |     |     "
  puts "  #{squares[1]}  |  #{squares[2]}  |  #{squares[3]}  "
  puts "_____|_____|_____"
  puts "     |     |     "
  puts "  #{squares[4]}  |  #{squares[5]}  |  #{squares[6]}  "
  puts "_____|_____|_____"
  puts "     |     |     "
  puts "  #{squares[7]}  |  #{squares[8]}  |  #{squares[9]}  "
  puts "     |     |     "
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def prompt(message)
  puts "=> #{message}"
end

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def joinor(arr, delimiter=', ', word='or')
  arr[-1] = "#{word} #{arr.last}" if arr.size > 1
  arr.size == 2 ? arr.join(' ') : arr.join(delimiter)
end

def player_places_piece!(brd)
  square = INITIAL_MARKER

  loop do
    prompt "Choose a position to place a piece: #{joinor(empty_squares(brd), ', ')}"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt("Sorry that is not a valid choice")
  end

  brd[square] = PLAYER_MARKER
end

def find_at_risk_square(line, board, marker)
  if board.values_at(*line).count(marker) == 2
    board.select{|k,v| line.include?(k) && v == INITIAL_MARKER}.keys.first
  else
    nil
  end
end

def computer_places_piece!(brd)
  square = nil

  WINNING_LINES.each do |line|
    square = find_at_risk_square(line, brd, COMPUTER_MARKER)
    break if square
  end

  if !square
    WINNING_LINES.each do |line|
      square = find_at_risk_square(line, brd, PLAYER_MARKER)
      break if square
    end
  end

  if brd[5] == INITIAL_MARKER
    square = 5
  end

  if !square  
      square = empty_squares(brd).sample
  end

  brd[square] = COMPUTER_MARKER
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 3
      return 'Player'
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end
  nil
end

def someone_one?(brd)
  !!detect_winner(brd)
end

player_score = 0
computer_Score = 0

system 'clear'

loop do
  prompt("Would you like to go first?")
  CHOOSE = gets.chomp.downcase
  break if CHOOSE == 'no' || CHOOSE == 'yes'
  prompt("That is not a valid choice")
end

loop do
  board = initialize_board
  display_board(board, player_score, computer_Score)

  loop do
    display_board(board, player_score, computer_Score)
    if CHOOSE == 'yes'
      player_places_piece!(board)
      display_board(board, player_score, computer_Score)
      break if someone_one?(board) || board_full?(board)

      computer_places_piece!(board)
      break if someone_one?(board) || board_full?(board)
    else
      computer_places_piece!(board)
      display_board(board, player_score, computer_Score)
      break if someone_one?(board) || board_full?(board)

      player_places_piece!(board)
      display_board(board, player_score, computer_Score)
      break if someone_one?(board) || board_full?(board)
    end
  end

  display_board(board, player_score, computer_Score)

  if someone_one?(board)
    prompt("#{detect_winner(board)} won!")
    detect_winner(board) == 'Player' ? player_score += 1 : computer_Score += 1
  else
    prompt("It's a tie!")
  end


  if player_score == 5 || computer_Score == 5
    display_board(board, player_score, computer_Score)
    break
  end
end

prompt("Thanks for playing!")
