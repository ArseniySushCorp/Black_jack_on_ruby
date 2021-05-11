class Game
  include Variables

  attr_reader :player, :dialer, :players

  def initialize(player_name)
    @game_bank = 0
    @player = Player.new(INITIAL_BANK, player_name)
    @dialer = Dialer.new(INITIAL_BANK)
    @players = [@player, @dialer]
  end

  def start
    Shuffle.new(self)
  end

  def destribution
    @deck = create_deck

    @players.each { |p| p.cards = @deck.shift(2) }
  end

  def add_card(person)
    person.add_card(@deck.shift) if person.two_cards?
  end

  def place_bet
    @players.each(&:place_bet)

    @game_bank += RATE * @players.size
  end

  def define_winner
    win(@players.find(&:not_lost?)) if someone_lost?

    draw if @player.points == @dialer.points

    win(@player) if @player.points > @dialer.points
    win(@dialer) if @dialer.points > @player.points
  end

  def game_over
    @players.each(&:fold_cards)
    @deack = create_deck

    @game_bank = 0
  end

  private

  def create_deck
    CARD_VALUES.map { |card_value| SUITS.map { |suit| { value: card_value, suit: suit } } }.flatten!.shuffle
  end

  def someone_lost?
    @players.any?(&:lost?)
  end

  def draw
    @players.each { |p| p.bank += @game_bank / @players.size }
    DRAW
  end

  def win(player)
    player.bank += @game_bank
    player
  end
end
