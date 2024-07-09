# frozen-string-literal: true

require_relative 'pieces'
require_relative 'player'
require 'pry-byebug'

# main game class. holds methods for the board, and calls to pieces for creating and updating pieces
class Chess
  attr_reader :player1, :player2

  def initialize
    @board = { a: ["\u265c ", "\u265e ", "\u265d ", "\u265b ", "\u265a ", "\u265d ", "\u265e ", "\u265c "],
               b: ["\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f ", "\u265f "],
               c: %w[_ _ _ _ _ _ _ _],
               d: %w[_ _ _ _ _ _ _ _],
               e: %w[_ _ _ _ _ _ _ _],
               f: %w[_ _ _ _ _ _ _ _],
               g: ["\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 ", "\u2659 "],
               h: ["\u2656 ", "\u2658 ", "\u2657 ", "\u2655 ", "\u2654 ", "\u2657 ", "\u2658 ", "\u2656 "] }
    @player1 = Player.new(1)
    @player2 = Player.new(2)
    @current_turn = @player2.side
  end

  def choose_piece(player)
    valid_piece = false
    piece = []
    while valid_piece == false
      puts 'Select your piece!\nPick a row from A to Z'
      piece[0] = gets.chomp
      puts 'Pick a column from 1 to 8'
      piece[1] = gets.chomp.to_i
      valid_piece = true if player.value?(piece)
    end
    piece
  end
end
