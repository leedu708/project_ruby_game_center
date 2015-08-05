class ConnectFour

  attr_accessor :player1, :player2, :player

  def initialize
    @board = Board.new
  end

  def play

    # sets current player to player 1
    game_mode(get_game_mode)
    @player = @player1

    # loop until victory conditions are satisfied
    loop do
      @board.render
      @player.get_move

      break if game_over?
      swap_player
    end

    @board.render
    end_game
  end

  def get_game_mode

    # asks user who they would like to play against
    puts "Would you like to play against the computer (1), or against another player (2)?"

    # ensures valid input from user
    input = gets.chomp.to_i
    until [1, 2].include?(input)
      puts "Invalid input.  Please input a '1' or a '2'."
      input = gets.chomp.to_i
    end
    input

  end

  def game_mode(input)

    # player vs. computer
    if input == 1
      @player1 = Human.new("Player 1", :x, @board)
      @player2 = Computer.new("Computer", :o, @board)

    # player1 vs. player2
    else
      @player1 = Human.new("Player 1", :x, @board)
      @player2 = Human.new("Player 2", :o, @board)
    end

  end

  def game_over?
    # game is over if someone wins or board is full
    @board.victory? || @board.full?
  end

  def swap_player

    # alternates player turns
    if @player == @player1
      @player = @player2
    else
      @player = @player1
    end

  end

  def end_game

    # end game message
    if @board.victory?
      puts "#{@player.name} is the winner!"
    else
      puts "The board is full, it's a draw!"
    end

  end

end

class Board
  attr_reader :game_board

  def initialize(game_board = nil)

    # sets up game board as 6 x 7 grid of '-'s
    @game_board = game_board
    @game_board ||= Array.new(7) { Array.new(6) { :- } }

  end

  def render

    # prints column numbers and board state
    puts "\n1  2  3  4  5  6  7\n"

    # prints current piece state
    @game_board.transpose.each do |column|
      column.each { |piece_state| print "#{piece_state}  "}
      puts
    end
    puts

  end

  def add_piece(column, piece)

    # check if column is full ie. checks top piece if empty or not
    if @game_board[column - 1][0] == :-
      @game_board[column - 1].length.downto(0) do |row|

        # only place piece into furthest empty space
        if @game_board[column - 1][row] == :-
          @game_board[column - 1][row] = piece
          break
        end
      end

      return true

    else
      puts "This column is full.  Choose another column."
    end

  end

  def full?

    # returns true if each column is full
    @game_board.each do |column|
      return false if column.include?(:-)
    end

    true
  end

  def victory?(current_board = @game_board)

    # returns true if vertical, horizontal, or diagonal connect 4 is on the board
    vertical?(current_board) || horizontal?(current_board) || diagonal?(current_board)

  end

  def vertical?(board)

    # checks for vertical connect 4
    # keeps track of consecutive pieces
    board.each do |column|
      consecutive_pieces = 0
      current_piece = column[0]

      column.each_with_index do |element, index|
        # if an empty space is reached, consecutive count is reset
        if element == :-
          consecutive_pieces = 0
          current_piece = column[index + 1]
          next
        end

        # if the current space is the same piece, increment consecutive count
        if element == current_piece
          consecutive_pieces += 1
          return true if consecutive_pieces >= 4

        # sets consecutive count to 1 on first piece encounter
        else
          consecutive_pieces = 1
          current_piece = element
        end
      end
    end

    false
  end

  def horizontal?(board)

    # checks horizontal connect 4 by transposing board and inputing into vertical? method
    vertical?(board.transpose)

  end

  def diagonal?(board)

    check_diagonal(board, 1) || check_diagonal(board, -1)

  end

  def check_diagonal(board, step)

    # goes through each space by setting a first space
    (0..6).each do |column|
      (0..5).each do |row|

        # checks through current piece
        current_piece = board[column][row]
        consecutive_pieces = 0

        col_check = column
        row_check = row

        # goes through each column
        6.times do 
          # resets count if there is an empty space
          if board[col_check][row_check] == :-
            consecutive_pieces = 0
            current_piece = board[col_check + 1][row_check + step] if (0..6).include?(col_check + 1) && (0..5).include?(row_check + step)
          elsif board[col_check][row_check] == current_piece
            consecutive_pieces += 1
            return true if consecutive_pieces >= 4
          else
            consecutive_pieces = 1
            current_piece = board[col_check][row_check]
          end

          col_check += 1
          row_check += step

          break if col_check >= 7 || row_check >= 6 || col_check < 0 || row_check < 0

        end
      end
    end
    false
  end
end

class Player
  attr_reader :name

  def initialize(name, piece, board)
    @name = name
    @piece = piece
    @board = board
  end

end

class Human < Player

  def get_move

    # puts piece in indicated column
    print "#{@name}, which column would you like to play your piece?\s"

    # only makes move if column choice is valid
    loop do
      column = get_column
      if valid_play?(column)
        break if @board.add_piece(column, @piece)
      end
    end

  end

  # private getter method for column input
  private
  def get_column
    gets.chomp.to_i
  end

  def valid_play?(column)

    # checks to see if column input is between 1 and 7
    if (1..7).include?(column)
      return true
    else
      puts "You must choose a column between 1 and 7."
    end

  end

end

class Computer < Player

  def get_move

    loop do
      break if @board.add_piece(comp_move, @piece)
    end

  end

  def comp_move

    # determines computer move
    (1..7).each do |column|
      comp_board = []
      player_board = []

      # duplicate game_board for checking board state
      @board.game_board.each { |column| comp_board << column.dup }
      @board.game_board.each { |column| player_board << column.dup }

      # uses new board to play piece and checks for victory

      # checks for computer victory
      if comp_piece(column, @piece, comp_board)
        if @board.victory?(comp_board)
          return column
        end
      end

      # checks for player victory
      if comp_piece(column, :x, player_board)
        if @board.victory?(player_board)
          return column
        end
      end

    end

    # play a random move
    rand(1..7)

  end

  def comp_piece(column, piece, comp_board)

    # adding piece on duplicated board for checking victory conditions
    if comp_board[column - 1][0] == :-
      comp_board[column - 1].length.downto(0) do |index|
        if comp_board[column - 1][index] == :-
          comp_board[column - 1][index] = piece
          break
        end
      end
      return true
    else
      return false
    end

  end

end

test = ConnectFour.new
test.play