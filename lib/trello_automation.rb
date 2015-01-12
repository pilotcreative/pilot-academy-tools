require 'trello_automation/board_duplicator'

class TrelloAutomation

  def start
    bd = BoardDuplicator.new
    bd.call
  end
end
