# -*- coding: utf-8 -*-
require 'trello_automation/board_duplicator'
require 'trello_automation/configuration'

module TrelloAutomation
  class AutomationManager
    include Configuration

    def start(argv)
      configuration
      case argv[0]
      when nil
        logger.warn { Constants::NO_ARGS }
      when 'authorize'
        Authorization.authorize
        logger.info { Constants::AUTH_OK }
      when 'copy'
        copy_board(argv)
      when 'clone'
        clone_board(argv)
      when 'close_all_but'
        close_boards(argv)
      when 'show'
        show_boards(argv)
      else
        logger.warn { "Wrong arguments: #{argv}" }
      end
    end

    private

    def copy_board(argv)
      logger.info { 'Creating board copy...' }
      BoardDuplicator.new.call(argv[1])
    end

    def clone_board(argv)
      if argv[2].nil?
        logger.warn { Constants::NO_MEMBERS }
        return
      end
      BoardDuplicator.subscription_list(argv.slice(4..(argv.length - 1))) if argv[3] == 'subscribe'
      board_duplicator, board_url, members_list_path = BoardDuplicator.new, argv[1], argv[2]
      if members_names = names(members_list_path)
        members_names.each do |full_member_name, trello_nickname|
          board_duplicator.call(board_url, trello_nickname: trello_nickname,
                                           full_member_name: full_member_name)
        end
      end
    end

    def close_boards(argv)
      filter = argv[1].nil? ? 'starred' : argumentize(argv, 1)
      BoardDuplicator.new.close_boards(filter)
    end

    def show_boards(argv)
      filter = argv[1] || 'open'
      fields = argv[2].nil? ? 'name' : argumentize(argv, 2)
      puts BoardDuplicator.new.show(filter, fields)
    end

    def names(members_list_path)
      return false if members_list_path.nil?
      names = []
      File.open(members_list_path, encoding: 'utf-8').each do |line|
        /^(?<full_member_name>.*)<(?<trello_nickname>.*)>$/ =~ line
        names << [full_member_name, trello_nickname]
      end
      names
    end

    def argumentize(input, starting_point)
      input.slice(starting_point..(input.length - 1)).to_s[1..-2].delete('"').delete(' ')
    end
  end
end
