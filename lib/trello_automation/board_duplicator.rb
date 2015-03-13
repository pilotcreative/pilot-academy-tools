module TrelloAutomation
  class BoardDuplicator
    def call(board_url, options = {})
      Authorization.authorize
      logger.info("Cloning for: #{options[:trello_nickname]}") if options[:trello_nickname]
      original_board = find_board_by_url(board_url)
      cloned_board_id = clone_board(original_board, options[:full_member_name])
      subscribe_me_to_chosen_lists_in(cloned_board_id)
      add_member(cloned_board_id, options[:trello_nickname]) if options[:trello_nickname]
    end

    def close_boards(filter)
      Authorization.authorize
      logger.info('Closing boards...')
      tokens_of_boards_to_close = []
      leave_out(filter).each { |e| tokens_of_boards_to_close << e['shortLink'] }
      # tokens_of_boards_to_close -= organizations_boards
      tokens_of_boards_to_close.each do |token|
        closed_board = JSON.parse(client.put("/boards/#{token}", closed: true))
        logger.info("Closed name: #{closed_board['name']}")
        logger.info("Closed URL:  #{closed_board['url']}")
      end
    end

    def self.subscription_list(array_with_lists)
      Constants::LISTS_TO_SUBSCRIBE_TO.delete_at(0)
      array_with_lists.each { |l| Constants::LISTS_TO_SUBSCRIBE_TO << l }
      Constants::LISTS_TO_SUBSCRIBE_TO
    end

    def show(filter, fields)
      Authorization.authorize
      all_boards(filter, fields)
    end

    private

    def organizations_boards
      organizations_boards_tokens = []
      all_boards('open', 'idOrganization,shortLink')
        .each { |e| organizations_boards_tokens <<
          e['shortLink'] unless e['idOrganization'].nil? }
      organizations_boards_tokens
    end

    def find_board_by_url(board_url)
      Trello::Board.find(board_token(board_url))
    end

    def clone_board(original_board, clone_name)
      clone_name ||= 'copy'
      idOrganization = original_board.organization_id
      name = "#{original_board.name} - #{clone_name}".strip
      cloned_board = client.post('/boards', name: name, idBoardSource: original_board.id, idOrganization: idOrganization)
      logger.info("Cloned board: #{name}.")
      logger.info("URL: #{JSON.parse(cloned_board)['url']}")
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
      logger.info("Filtering out: #{filter} ...")
      filtered_boards = (all_boards('open') - all_boards(filter))
      logger.info(Constants::NO_BOARDS) if filtered_boards.empty?
      filtered_boards
    end

    def all_boards(filter, fields = 'shortLink')
      JSON.parse(client.get('/members/me/boards', filter: filter, fields: fields))
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
      Constants::LISTS_TO_SUBSCRIBE_TO.each do |list|
        if cloned_lists.keys.include?(list.downcase)
          subscribe_member(cloned_lists[list.downcase])
          logger.info("Subscribed to #{list} in #{cloned_board.name}.")
        else
          new_list_id = JSON.parse(client.post("/boards/#{cloned_board_id}/lists", name: list, pos: 'bottom'))['id']
          subscribe_member(new_list_id)
          logger.info("Subscribed to newly created #{list} in #{cloned_board.name}.")
        end
      end
    end

    def add_member(board_id, trello_nickname)
      member = Trello::Member.find(trello_nickname)
      client.put("/boards/#{board_id}/members/#{member.id}", type: 'normal')
      board_name = client.find(:board, board_id).name
      logger.info("Added #{trello_nickname} to #{board_name}.")
    end

    def subscribe_member(done_list_id)
      client.put("/lists/#{done_list_id}/subscribed", value: true)
    end

    def client
      Trello.client
    end

    def logger
      Configuration.logger
    end
  end
end
