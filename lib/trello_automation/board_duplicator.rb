require 'trello_automation/authorization'
require 'json'
LISTS_TO_SUBSCRIBE_TO = ['Done'] # case insensitive

class BoardDuplicator
  def call(board_url, options = {})
    Authorization.authorize
    puts "\nCreating board copy for Trello user #{options[:trello_nickname]}..." if options[:trello_nickname]
    original_board = find_board_by_url(board_url)
    cloned_board_id = clone_board(original_board, options[:full_member_name])
    subscribe_me_to_chosen_lists_in(cloned_board_id)
    add_member(cloned_board_id, options[:trello_nickname]) if options[:trello_nickname]
  end

  def close_boards(filter = '')
    Authorization.authorize
    tokens_of_boards_to_close = []
    leave_out(filter).each { |e| tokens_of_boards_to_close << e['shortLink'] }
    tokens_of_boards_to_close.each do |token|
      closed_board = JSON.parse(client.put("/boards/#{token}", closed: true))
      name = closed_board['name']
      url = closed_board['url']
      puts "Closed board #{name}, URL: #{url}."
    end
  end

  def self.subscription_list(array_with_lists)
    LISTS_TO_SUBSCRIBE_TO.delete_at(0)
    array_with_lists.each { |l| LISTS_TO_SUBSCRIBE_TO << l }
    puts LISTS_TO_SUBSCRIBE_TO
  end

  private

  def find_board_by_url(board_url)
    Trello::Board.find(board_token(board_url))
  end

  def clone_board(original_board, clone_name)
    clone_name ||= 'copy'
    name = "#{original_board.name} - #{clone_name}".strip
    cloned_board = client.post('/boards', name: name, idBoardSource: original_board.id)
    url = JSON.parse(cloned_board)['url']
    puts "Created a copy of #{original_board.name} with the name #{name}."
    puts "Link to the clone board: #{url}"
    JSON.parse(cloned_board)['id']
  end

  def close_default_lists_in(board)
    board.lists.each { |list| list.close! }
  end

  def clone_lists_from_to(original_board, cloned_board_id)
    original_board.lists.each do |list|
      client.post('/lists', name: list.name, idBoard: cloned_board_id, pos: 'bottom')
    end
  end

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

  def subscribe_me_to_chosen_lists_in(cloned_board_id)
    cloned_board = Trello::Board.find(cloned_board_id)
    cloned_lists = {}
    client.find(:board, cloned_board_id).lists.map do |list|
      cloned_lists[list.name.downcase] = list.id
    end
    LISTS_TO_SUBSCRIBE_TO.each do |list|
      if cloned_lists.keys.include?(list.downcase)
        subscribe_member(cloned_lists[list.downcase])
        puts "You have been subscribed to the list #{list} in the board #{cloned_board.name}."
      else
        new_list_id = JSON.parse(client.post("/boards/#{cloned_board_id}/lists", name: list, pos: 'bottom' ))['id']
        subscribe_member(new_list_id)
        puts "You have been subscribed to the newly created list #{list} in the board #{cloned_board.name}."
      end
    end
  end

  def add_member(board_id, trello_nickname)
    member = Trello::Member.find(trello_nickname)
    client.put("/boards/#{board_id}/members/#{member.id}", type: 'normal')
    board_name = client.find(:board, board_id).name
    puts "Trello member #{trello_nickname} has been added to the board #{board_name}."
  end

  def subscribe_member(done_list_id)
    client.put("/lists/#{done_list_id}/subscribed", value: true)
  end

  def client
    client ||= Trello.client
  end
end
