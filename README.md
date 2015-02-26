# Trello Automation

Trello Automation gives you the ability to manage some humdrum Trello tasks quickly and effectively via the command line.

# Table of contents:

1. [Setup](#setup)
2. [Features](#features)
3. [Development](#development)

# Setup

1. Clone this repo:
`$ git clone https://github.com/pilotcreative/pilot-academy-tools/`
2. Navigate to the repo's folder and run:
`$ bundle install`
3. Authorize:
`$ ./trello_automation.sh authorize`

A browser should open with Trello asking you for permission. Allow and copy-paste the token from the browser to the terminal when prompted. You should see something like this:

```
Please paste your token:
0988a6d7c0d28d606def542e8282cba41fdc5411b5781d0e8d32fddc55807e0c
Authorization successful, you can use the script now.
```

Setup is required only once.

# Features

Trello Automation is a script that deliveres the following features to the command line:

1. [Copying a board](#copying-a-board)
2. [Cloning a board for specified users](#cloning-a-board-for-specified-users)
3. [Closing specified boards](#closing-specified-boards)
4. [Showing boards](#showing-boards)


## Copying a board

Command:

`$ ./trello_automation.sh copy <board_url>`

Makes a single copy of a linked board.
Names the copy in form `#{original_board_name} - copy`.
Gives you the link to the copy.
Subscribes you automatically to the copy's _**Done**_ list.
This list will be created if the original board does not have such.

####Example:

```
$ ./trello_automation.sh copy https://trello.com/b/vlQMjo8k/trello-automation
Creating board copy...
Created a copy of Trello Automation with the name Trello Automation - copy.
Link to the cloned board: https://trello.com/b/0Kzw3lTC/trello-automation-copy
You have been subscribed to the list Done in the board Trello Automation - copy.
```

## Cloning a board for specified users

#### [Basic command](#basic-flow):
`$ ./trello_automation.sh clone <board_url> <path/to/members_list>`
#### [Basic command with additional subscriptions](#flow-with-subscriptions):
`$ ./trello_automation.sh clone <board_url> <path/to/members_list> subscribe <lists_to_subscribe_to>`

#### Basic flow:
Clones a linked board for each user.
Names the copy in form `#{original_board_name} - #{trello_username_or_email}`.
Gives you the link to the clone board.
Subscribes you automatically to the clone's _**Done**_ list.
The _**Done**_ list will be created if the original board does not have such.
Adds to the clone board the designated user as a member.

`<path/to/members_list>` is a path to file with member names and their trello nicknames.
The `members_list` file can be given any name and extension (including none as in this example), but it has to be kept strictly in the following form:

```
Member Name <trello_nickname_or_email>
John Doe <jdoe>
Lorem Ipsum <cicero@ancient.rome>
```

In the above code all chars are literal. See sample [members_list file](https://github.com/pilotcreative/pilot-academy-tools/blob/master/members_list) for more explicit example.

####Example:

```
$ ./trello_automation.sh clone https://trello.com/b/vlQMjo8k/trello-automation members_list

Creating board copy for Trello user johnny...
Created a copy of Trello Automation with the name Trello Automation - John Doe.
Link to the clone board: https://trello.com/b/urtri18t/trello-automation-john-doe
You have been subscribed to the list Done in the board Trello Automation - John Doe.
Trello member johnny has been added to the board Trello Automation - John Doe.

Creating board copy for Trello user cicero...
Created a copy of Trello Automation with the name Trello Automation - Lorem Ipsum.
Link to the clone board: https://trello.com/b/t3dB7e1l/trello-automation-lorem-ipsum
You have been subscribed to the list Done in the board Trello Automation - Lorem Ipsum.
Trello member cicero has been added to the board Trello Automation - Lorem Ipsum.
```

In this case, `member_list` is a file in the home directory of the project, i.e. where the file `trello_automation.sh` sits (this path is relative).

#### Flow with subscriptions:

The flow with subscriptions is similar to the basic flow, except you will get subscribed to **all and only** the lists you specify. If some list does not exist, it will be created so you can be subscribed to it. The `subscribe` argument overrides the default behaviour, i.e. you will not get subscribed to any list, not even the _**Done**_ list, unless you specify it. You can give the `subscribe` argument alone if you do not want to get subscribed to the _**Done**_ list automatically when cloning boards for others.

####Example:

```
$ ./trello_automation.sh clone https://trello.com/b/vlQMjo8k/trello-automation members_list subscribe HelpMeList CheckThisOut

Creating board copy for Trello user johnny...
Created a copy of Trello Automation with the name Trello Automation - John Doe.
Link to the clone board: https://trello.com/b/Vw75UOmA/trello-automation-john-doe
You have been subscribed to the newly created list HelpMeList in the board Trello Automation - John Doe.
You have been subscribed to the newly created list CheckThisOut in the board Trello Automation - John Doe.
Trello member johnny has been added to the board Trello Automation - John Doe.

Creating board copy for Trello user cicero...
Created a copy of Trello Automation with the name Trello Automation - Lorem Ipsum.
Link to the clone board: https://trello.com/b/BwdLOXQS/trello-automation-lorem-ipsum
You have been subscribed to the newly created list HelpMeList in the board Trello Automation - Lorem Ipsum.
You have been subscribed to the newly created list CheckThisOut in the board Trello Automation - Lorem Ipsum.
Trello member cicero has been added to the board Trello Automation - Lorem Ipsum.
```

Take note you will not get subscribed automatically to the _**Done**_ list if using the `subscribe` argument!

##Closing boards:

Command:

`$ ./trello_automation.sh close_all_but [filter]`

The script will iterate over all open boards and leave out these filtered.
Valid [`filter`](https://trello.com/docs/api/member/index.html#get-1-members-idmember-or-username-boards) filters are:

`members organization pinned public starred unpinned`

The default filter is `starred`. Just as with using [`subscribe`](#flow-with-subscriptions), using filters overrides the default behaviour, i.e. the script will filter out **all and only** the boards you tell it to. If you try to close boards you do not have access to, you will get an error:

```
ERROR -- : [401 PUT https://api.trello.com/1/boards/#{shortLink}]: unauthorized permission requested
````

####Example:

```
$ ./trello_automation.sh close_all_but
```

This will close all boards but for the `starred` ones, which is the default filter, whereas this:

```
$ ./trello_automation.sh close_all_but pinned public
```

will close all boards but for the `pinned` and `public` ones.

##Showing boards

Command:

`$ ./trello_automation show [filter] [fields]`

Both the `filter` and `fields` are optional arguments.
Valid [arguments](https://trello.com/docs/api/member/index.html#get-1-members-idmember-or-username-boards):
```
filters: closed members open organization pinned public starred unpinned
fields: closed dateLastActivity dateLastView desc descData idOrganization invitations invited labelNames memberships name pinned powerUps prefs shortLink shortUrl starred subscribed url
```

This command gives you the hash of `filter`ed out boards with specified `fields`, always including the `id` of a board.
If no arguments are given, the default ones are `open` and `name` for `filter` and `fields` respectively.

####Example:

```
$ ./trello_automation.sh show
{"name"=>"Academy Chat Gnu", "id"=>"54b4e25053d2ee874f475688"}
{"name"=>"Pilot Academy Workshop: Jasmine - Maciej Kalisz ", "id"=>"54e1c974230db2be2ce6f9c6"}
{"name"=>"Trello Automation", "id"=>"54eb095f8926def9d57adacd"}
{"name"=>"Trello Automation - John Doe", "id"=>"54edc24a41ef3728bd9c5e9f"}
{"name"=>"Trello Automation - Lorem Ipsum", "id"=>"54edc24fc6ad4298cc6da2ee"}
{"name"=>"Welcome Board", "id"=>"54b3dda9bf34908378d58b05"}
```

A handy use:

```
$ ./trello_automation.sh show open url name > links.txt
```

This provides you with the following `links.txt` file, which contains `name`, `id`, and `url` of each of all `open` boards:

```
{"name"=>"Academy Chat Gnu", "id"=>"54b4e25053d2ee874f475688", "url"=>"https://trello.com/b/Hwjry1aD/academy-chat-gnu"}
{"name"=>"Pilot Academy Workshop: Jasmine - Maciej Kalisz ", "id"=>"54e1c974230db2be2ce6f9c6", "url"=>"https://trello.com/b/JRUY2s5N/pilot-academy-workshop-jasmine-maciej-kalisz"}
{"name"=>"Trello Automation", "id"=>"54eb095f8926def9d57adacd", "url"=>"https://trello.com/b/vlQMjo8k/trello-automation"}
{"name"=>"Trello Automation - John Doe", "id"=>"54edc24a41ef3728bd9c5e9f", "url"=>"https://trello.com/b/SPc5czV3/trello-automation-john-doe"}
{"name"=>"Trello Automation - Lorem Ipsum", "id"=>"54edc24fc6ad4298cc6da2ee", "url"=>"https://trello.com/b/ivmf2puA/trello-automation-lorem-ipsum"}
{"name"=>"Welcome Board", "id"=>"54b3dda9bf34908378d58b05", "url"=>"https://trello.com/b/Z6d6H8Pf/welcome-board"}

```

##Development

Please send any feedback to [mdkalish](https://github.com/mdkalish) or [laserchicken](https://github.com/laserchicken).
