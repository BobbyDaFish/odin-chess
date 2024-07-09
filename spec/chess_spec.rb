# frozen-string-literal: true

require '../lib/chess'

describe Chess do
  subject(:game) { described_class.new }

  describe '#choose_piece' do
    before do
      allow(game).to receive(:gets).and_return('a', '1')
    end

    it 'returns the move selection if valid' do
      array = game.choose_piece({ position: ['a', 1] })
      expect(array).to eql(['a', 1])
    end
  end

  describe '#choose_move' do
    describe 'user inputs a valid move selection' do
      before do
        allow(game).to receive(:possible_moves).and_return([['c', 1], ['d', 1]])
        allow(game).to receive(:gets).and_return('d', '1')
      end

      it 'returns the selection of a valid move' do
        move = game.choose_move(['b', 1])
        expect(move).to eql(['d', 1])
      end
    end

    describe 'user inputs invalid selection' do
      before do
        allow(game).to receive(:possible_moves).and_return([['c', 1], ['d', 1]])
        allow(game).to receive(:gets).and_return('e', '1')
      end

      it 'returns false' do
        move = game.choose_move(['b', 1])
        expect(move).to be false
      end
    end
  end

  describe '#possible_moves' do
    before do
      allow(game).to receive(:king_moves).and_return([['h', 4], ['g', 4], ['g', 5], ['g', 6], ['h', 6]])
      allow(game).to receive(:knight_moves).and_return([['f', 1], ['f', 3]])
    end

    it 'returns array of possible moves as sub arrays for the white side king' do
      moves = game.possible_moves(game.current_turn, ['h', 5])
      expect(moves).to eql([['h', 4], ['g', 4], ['g', 5], ['g', 6], ['h', 6]])
    end

    it 'returns array of possible moves from starting position for left white knight' do
      moves = game.possible_moves(game.current_turn, ['h', 2])
      expect(moves).to eql([['f', 1], ['f', 3]])
    end
  end
end
