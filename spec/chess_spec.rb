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
end
