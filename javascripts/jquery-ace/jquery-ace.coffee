window.jQueryAce =
  initialize: (element, options) ->
    klass = switch true
      when $(element).is('textarea')
        jQueryAce.TextareaEditor
      else
        jQueryAce.BaseEditor

    new klass element, options

  defaults:
    theme: null
    mode:  null

  version: '1.0.0'

class jQueryAce.BaseEditor
  constructor: (element, options = {}) ->
    @element = $(element)
    @options = $.extend {}, jQueryAce.defaults, options

  create: ->
    @editor = new jQueryAce.AceDecorator(ace.edit @element)
    @update()

  update: (options) ->
    @options = $.extend {}, @options, option if options?
    @editor.theme @options.theme if @options.theme?
    @editor.mode  @options.mode  if @options.mode?

  destroy: ->
    @element.data 'ace', null
    @editor.destroy()
    @element.empty()

class jQueryAce.TextareaEditor extends jQueryAce.BaseEditor
  show: ->
    @container?.show()
    @element.hide()

  hide: ->
    @container?.hide()
    @element.show()

  create: ->
    @container = @createAceContainer()
    @editor    = new jQueryAce.AceDecorator(ace.edit @container.get 0)

    @update()
    @editor.value @element.val()

    @editor.ace.on 'change', (e) =>
      @element.val @editor.value()

    @show()

  destroy: ->
    super()
    @hide()
    @container.remove()

  createAceContainer: ->
    @buildAceContainer().insertAfter @element

  buildAceContainer: ->
    $('<div></div>').css
      display:  'none'
      position: 'relative'
      width:    @element.width()
      height:   @element.height()

class jQueryAce.AceDecorator
  constructor: (@ace) ->

  theme: (themeName) ->
    @ace.setTheme "ace/theme/#{themeName}"

  mode: (modeName) ->
    klass = window.require("ace/mode/#{modeName}").Mode
    @session().setMode new klass

  session: ->
    @ace.getSession()

  destroy: ->
    @ace.destroy()

  value: (text) ->
    if text?
      @ace.insert text
    else
      @ace.getValue()

(($) ->
  $.ace = (element, options) ->
    $(element).ace options

  $.fn.ace = (options) ->
    @each ->
      editor = $(@).data 'ace'

      if editor?
        editor.update options
      else
        editor = jQueryAce.initialize @, options
        editor.create()

        $(@).data 'ace', editor
)(jQuery)
