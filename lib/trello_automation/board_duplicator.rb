require 'trello_automation/authorization'

class BoardDuplicator

  def call(board_url, options = {})
    Authorization.authorize
    board = Trello::Board.find(board_token(board_url))

    board_subname = " - " + options[:full_member_name]
    duplicatedBoard = Trello::Board.create({name: "#{board.name}#{board_subname}",
                                            organization_id: board.organization_id})

    duplicatedBoard.lists.each { |list| list.close! }

    duplicated_todo_list = nil;

    board.lists.reverse.each do |list|
      duplicatedList = Trello::List.create({name: list.name,
                                            board_id: duplicatedBoard.id})

      if /done/i =~ list.name
        duplicated_todo_list = duplicatedList
        puts duplicated_todo_list.name
      end

      list.cards.reverse.each do |card|
        Trello::Card.create({name: card.name,
                             list_id: duplicatedList.id,
                             desc: card.desc})
      end

    end

    add_member(duplicatedBoard.id, options[:member_name]) if options[:member_name]
    subscribe_member(duplicated_todo_list.id, options[:member_name]) if options[:member_name]
  end

  private

  def board_token(board_url)
    /.*trello.com\/b\/(?<token>.*)\/.*/ =~ board_url
    token
  end

  def add_member(board_id, member_name)
    client = Trello.client
    member = Trello::Member.find(member_name)
    path = "/boards/#{board_id}/members/#{member.id}"
    client.put(path, type: 'normal')
  end

  def subscribe_member(duplicated_todo_list_id, member_name)
    client = Trello.client
    member = Trello::Member.find(member_name)
    path = "/lists/#{duplicated_todo_list_id}/subscribed"
    client.put(path, value: true)
  end
end
