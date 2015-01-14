require 'trello_automation/authorization'

class BoardDuplicator

  def call(url)
    Authorization.authorize
    board = Trello::Board.find(board_token(url))

    duplicatedBoard = Trello::Board.create({name: "#{board.name}-mkm",
                                            organization_id: board.organization_id})

    duplicatedBoard.lists.each { |list| list.close! }

    board.lists.reverse.each do |list|
      duplicatedList = Trello::List.create({name: list.name,
                                            board_id: duplicatedBoard.id})

      list.cards.each do |card|
        Trello::Card.create({name: card.name,
                             list_id: duplicatedList.id,
                             desc: card.desc})
      end

    end

  end

  private

  def board_token(url)
    /.*trello.com\/b\/(?<token>.*)\/.*/ =~ url
    puts token
  end
end
