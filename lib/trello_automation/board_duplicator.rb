require 'trello_automation/authorization'

class BoardDuplicator

  def call
    Authorization.authorize

    board = Trello::Board.find('w9r5icGE')
  end

end
