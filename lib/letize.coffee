{CompositeDisposable} = require 'atom'

module.exports = Letize =
  subscriptions: null

  config:
    stripFactoryGirl:
      title:       'Strip `FactoryGirl.`'
      description: 'Strip `FactoryGirl.` out of `FactoryGirl.create` and such'
      type:        'boolean'
      default:     true

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'letize:toggle': => @toggle()

  toggle: ->
    editor            = atom.workspace.getActiveTextEditor()
    nothing_selected  = true

    return unless editor
    editor.splitSelectionsIntoLines()

    for selection in editor.getSelections()
      if selection.getText() != ''
        nothing_selected        = false
        line_range              = selection.getBufferRange()
        line_range.start.column = 0
        line_range.end.column   = 999
        text                    = editor.getTextInBufferRange(line_range)

        if letized = @letized text
          editor.setTextInBufferRange line_range, @letized(text)

    return if nothing_selected is false
    for cursor in editor.getCursors()
      text    = cursor.getCurrentBufferLine()
      range   = cursor.getCurrentLineBufferRange()
      if letized = @letized text
        editor.setTextInBufferRange range, @letized(text)

  letized: (orig)->
    return unless matches  = orig.match @letregex()
    [variable, expression] = matches[1..2]
    return unless variable and expression
    "let(:#{variable}) { #{expression} }"

  letregex: ->
    if atom.config.get('letize.stripFactoryGirl') == true
      ///
        \s*                                                 # Leading space
        @?                                                  # Strip out @instance variable if there
        (\S+)                                               # The variable name
        \s*=\s*                                             # =
        (?:FactoryGirl\.)?                                  # Strip out `FactoryGirl.` if present
        ?((?:create|build|build_stubbed|attributes_for).*)$ # Rest of the line is the expression
      ///i
    else
      ///
        \s*                                                 # Leading space
        @?                                                  # Strip out @instance variable if there
        (\S+)                                               # The variable name
        \s*=\s*                                             # =
        ?((?:create|build|build_stubbed|attributes_for).*)$ # Rest of the line is the expression
      ///i
