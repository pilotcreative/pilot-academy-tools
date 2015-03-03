module Constants
  DEVELOPER_PUBLIC_KEY  = 'bf9a0ddb8c4cb08bf7c9223e12675705'
  APP_NAME              = 'Trello Automation'
  LISTS_TO_SUBSCRIBE_TO = ['Done'] # case insensitive

  NO_ARGS    = 'You must specify at least one argument!'
  AUTH_OK    = 'Authorization successful, you can use the script now.'
  NO_MEMBERS = "You didn't specify members the clones should be made for." \
               "Perhaps you wanted to 'copy' rather than 'clone'?"
  NO_BOARDS  = 'No boards to close after filtering!'
end
