# frozen-string-literal: true

require_relative 'pieces'
require_relative 'player'
require_relative 'moves'
require_relative 'board'
require 'pry-byebug'

# Hold methods for game logic like updating and displaying board, accepting player input for moves
# and determining check/mate
class Chess
  attr_accessor :current_turn, :next_turn

  def initialize
    @player1 = Player.new(1)
    @player2 = Player.new(2)
    @current_turn = @player2
    @next_turn = @player1
    @movement = Moves.new
    @game_board = Board.new
  end

  def choose_piece
    loop do
      piece = []
      puts "Select a #{@current_turn.side} piece!\nPick a column from A to H"
      piece << gets.chomp
      puts 'Choose a row from 1 to 8'
      piece << gets.chomp.to_i
      @current_turn.pieces.pieces.select { |_k, v| return piece if piece == v[:position] }
      puts 'Invalid selection!'
    end
  end

  def choose_move(piece_coords)
    move = []
    puts "Where are you moving?\nPick a column from A to H"
    move << gets.chomp
    puts 'Choose a row from 1 to 8'
    move << gets.chomp.to_i
    return move if @movement.possible_moves(@current_turn, piece_coords, @next_turn).any?(move)

    puts 'Invalid move, select a piece and try again.'
    false
  end

  # sets the new piece coords, then calls method to find and resolve any piece takes
  def process_move(piece, move)
    @current_turn.pieces.pieces.each_value do |v|
      if v[:position] == piece
        v[:position] = move
        return resolve_takes(v)
      end
    end
  end

  # checks if current players pieces share position coordinates with next players piece.
  # If so, set next player's piece position to [] to remove from board
  def resolve_takes(piece)
    @next_turn.pieces.pieces.each_value do |opp_piece|
      if piece[:position] == opp_piece[:position]
        opp_piece[:position] = nil
        return opp_piece
      end
    end
    []
  end

  def find_check # rubocop:disable Metrics
    king = @current_turn.pieces.pieces[:king][:position]
    swap_turn(@current_turn)
    @current_turn.pieces.pieces.each_value do |piece|
      next if piece[:position].nil?

      moves = @movement.possible_moves(@current_turn, piece[:position], @next_turn)
      next if moves.nil?

      moves.each do |threat|
        swap_turn(@current_turn) if threat == king
        return true if threat == king
      end
    end
    swap_turn(@current_turn)
    false
  end

  def find_mate
    @current_turn.pieces.pieces.each do |k, v|
      next if v[:position].nil?

      player_state = @current_turn.pieces.pieces[k][:position]
      pos_moves = @movement.possible_moves(@current_turn, v[:position], @next_turn)
      return false unless mate?(pos_moves, v, player_state)
    end
    true
  end

  def mate?(pos_moves, piece, state)
    pos_moves.each do |move|
      taken_piece = process_move(piece[:position], move)
      check = find_check
      piece[:position] = state
      taken_piece[:position] = move unless taken_piece.empty?
      return false unless check
    end
    true
  end

  def swap_turn(player = @player2)
    if player.side == 'white'
      @current_turn = @player1
      @next_turn = @player2
    else
      @current_turn = @player2
      @next_turn = @player1
    end
  end

  def play_move
    loop do
      piece = choose_piece
      move = choose_move(piece)
      next if move == false

      taken_piece = process_move(piece, move)
      return unless find_check

      taken_piece[:position] = move unless taken_piece.empty?
      @current_turn.pieces.pieces.select { |_k, h| h[:position] = piece if h[:position] == move }
      puts 'This move has you in check. Invalid move, try again.'
    end
  end

  def play_game
    swap_turn(@game_board.load?(@player1, @player2))
    loop do
      @game_board.update_board(@current_turn, @next_turn)
      @game_board.save_game(@player1.pieces.pieces, @player2.pieces.pieces, @current_turn.side)
      @game_board.display_board
      mate = find_mate if find_check
      return if mate

      play_move
      swap_turn(@current_turn)
    end
  end
end
