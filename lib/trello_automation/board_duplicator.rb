require 'trello_automation/authorization'
require 'json'
LISTS_TO_SUBSCRIBE_TO = ['Done'] # case insensitive

class BoardDuplicator
  def call(board_url, options = {})
    # p options #>  {:member_nickname=>"johnny", :full_member_name=>"John Doe "}
    Authorization.authorize
    original_board = find_board(board_url)
    cloned_board = clone_board(original_board, options[:full_member_name])
    cloned_board = find_board(JSON.parse(cloned_board)['url'])
    close_default_lists_in(cloned_board)
    clone_lists_from_to(original_board, cloned_board.id)
    # clone_cards_from_to(original_board, cloned_board)
    # board.lists.reverse.each do |list|
    #   @done_list = list if LISTS_TO_SUBSCRIBE_TO.each{ |e| e.downcase! }.include?(list.name.downcase!)
    #   list_copy = Trello::List.create(name: list.name, board_id: board_users_copy.id)
    #   list.cards.reverse.each do |card|
    #     Trello::Card.create(name: card.name,
    #                         list_id: list_copy.id,
    #                         desc: card.desc)
    #   end
    # end
    # p board_users_copy.lists.map(&:name).any? { |e| e =~ /done/i }
    # p board_users_copy.lists.find()
    # p board_users_copy.lists.pluck(:name).include?(/done/i)
    # subscribe_me_to_users_done_list(@done_list, board_users_copy.id, options[:full_member_name])
    # add_member(board_users_copy.id, options[:member_nickname]) if options[:member_nickname]
  end

  def close_boards(filter = '')
    Authorization.authorize
    tokens_of_boards_to_close = []
    leave_out(filter).each { |e| tokens_of_boards_to_close << e['shortLink'] }
    tokens_of_boards_to_close.each do |token|
      name = JSON.parse(client.put("/boards/#{token}", {closed: true}))['name']
      puts "Closed board #{name.strip} (shortLink: #{token})."
    end
  end

  private

  def find_board(board_url)
    Trello::Board.find(board_token(board_url))
  end

  def clone_board(original_board, clone_name)
    clone_name ||= 'copy'
    client.post('/boards',
                name: "#{original_board.name} - #{clone_name}",
                organization_id: original_board.organization_id)
  end

  def close_default_lists_in(board)
    board.lists.each { |list| list.close! }
  end

  def clone_lists_from_to(original_board, cloned_board_id)
    original_board.lists.each do |list|
      client.post('/lists', name: list.name, idBoard: cloned_board_id, pos: 'bottom')
    end
  end

  # def clonecards_from_to()

  def leave_out(filter)
    (all_boards('open') - all_boards(filter))
  end

  def all_boards(filter)
    JSON.parse(client.get('/members/me/boards', filter: filter, fields: 'shortLink' ))
  end

  def board_token(board_url)
    %r{.*trello.com/b/(?<token>.*)/.*} =~ board_url
    token
  end

  def subscribe_me_to_users_done_list(done_list, board_id = '', member = '')
    if done_list
      subscribe_member(done_list.id)
    else
      done_list = Trello::List.create(name: 'Done', board_id: board_id)
      subscribe_member(done_list.id)
    end
    puts "You have been subscribed to the list '#{done_list.name}' of user #{member.strip}."
    p done_list.board_id
  end

  def add_member(board_id, member_nickname)
    client = Trello.client
    member = Trello::Member.find(member_nickname)
    path = "/boards/#{board_id}/members/#{member.id}"
    client.put(path, type: 'normal')
  end

  def subscribe_member(done_list_id)
    path = "/lists/#{done_list_id}/subscribed"
    client.put(path, value: true)
  end

  def client
    client ||= Trello.client
  end
end


# close a board: client.put("/boards/xdJ6Icuq", {closed: true})

# .scan(/(?<="name":")(.{8})/).flatten
      # if client.get("/boards/#{token}").include?("closed\":true") == false

    # %r{.*trello.com/b/(?<token>.*)/.*} =~ 'https://trello.com/b/khsx7Ez1/tat'
