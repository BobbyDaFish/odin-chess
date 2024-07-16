# frozen-string-literal: true

require_relative 'chess'
game = Chess.new
game.play_game
puts "Game over #{game.next_turn.side} wins!"
