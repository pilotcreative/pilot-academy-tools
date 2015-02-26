# -*- coding: utf-8 -*-
require 'trello_automation/board_duplicator'

module TrelloAutomation
  class AutomationManager
    def start(argv)
      case argv[0]
      when nil
        puts 'You must specify at least one argument!'
      when 'authorize'
        Authorization.authorize
        puts 'Authorization successful, you can use the script now.'
      when 'copy'
        copy_board(argv)
      when 'clone'
        clone_board(argv)
      when 'close_all_but'
        close_boards(argv)
      when 'show'
        show_boards(argv)
      end
    end

    private

    def copy_board(argv)
      puts "\nCreating board copy..."
      board_duplicator = BoardDuplicator.new
      board_duplicator.call(argv[1])
    end

    def clone_board(argv)
      if argv[2].nil?
        puts "You didn't specify members the clones should be made for. " \
        "Perhaps you wanted to 'copy' rather than 'clone'?"
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
      board_duplicator = BoardDuplicator.new
      argv[1].nil? ? filter = 'starred' : filter = argumentize(argv, 1)
      board_duplicator.close_boards(filter)
    end

    def show_boards(argv)
      board_duplicator = BoardDuplicator.new
      filter = argv[1] || 'open'
      fields = argv[2].nil? ? 'name' : argumentize(argv, 2)
      puts board_duplicator.show(filter, fields)
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
