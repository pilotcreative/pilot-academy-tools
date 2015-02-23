require 'trello_automation/authorization'
require 'json'
LISTS_TO_SUBSCRIBE_TO = ['Done'] # case insensitive

class BoardDuplicator
  def call(board_url, options = {})
    # p options #>  {:member_nickname=>"johnny", :full_member_name=>"John Doe "}
    Authorization.authorize
    board, board_users_copy = get_boards_array(board_url, options)
    # board_users_copy.lists.each { |list| list.close! }
    board.lists.reverse.each do |list|
      @done_list = list if LISTS_TO_SUBSCRIBE_TO.each{ |e| e.downcase! }.include?(list.name.downcase!)
      list_copy = Trello::List.create(name: list.name, board_id: board_users_copy.id)
      list.cards.reverse.each do |card|
        Trello::Card.create(name: card.name,
                            list_id: list_copy.id,
                            desc: card.desc)
      end
    end
    # p board_users_copy.lists.map(&:name).any? { |e| e =~ /done/i }
    # p board_users_copy.lists.find()
    # p board_users_copy.lists.pluck(:name).include?(/done/i)
    subscribe_me_to_users_done_list(@done_list, board_users_copy.id, options[:full_member_name])
    add_member(board_users_copy.id, options[:member_nickname]) if options[:member_nickname]
  end

  def close_boards(filter = 'starred')
    Authorization.authorize
    client
    boards_to_close_tokens = []
    leave_out(filter).each { |e| boards_to_close_tokens << e['shortLink'] }
    boards_to_close_tokens.each do |token|
      @client.put("/boards/#{token}", {closed: true})
      puts "Closed board #{token}."
    end
  end

  private

  def get_boards_array(board_url, options = {})
    board = Trello::Board.find(board_token(board_url))
    board_subname = options[:full_member_name] || 'copy'
    board_users_copy = Trello::Board.create(name: "#{board.name} - #{board_subname}",
                                      organization_id: board.organization_id)
    [board, board_users_copy]
  end

  def leave_out(filter)
    (all_boards('open') - all_boards(filter))
  end

  def all_boards(filter)
    JSON.parse(@client.get('/members/me/boards', filter: filter, fields: 'shortLink' ))
  end

  def board_token(board_url)
    %r{.*trello.com/b/(?<token>.*)/.*} =~ board_url
    # %r{.*trello.com/b/(?<token>.*)/.*} =~ 'https://trello.com/b/khsx7Ez1/tat'
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
    client = Trello.client
    path = "/lists/#{done_list_id}/subscribed"
    client.put(path, value: true)
  end

  def client
    @client ||= Trello.client
  end
end


# close a board: client.put("/boards/xdJ6Icuq", {closed: true})

# .scan(/(?<="name":")(.{8})/).flatten
      # if client.get("/boards/#{token}").include?("closed\":true") == false
