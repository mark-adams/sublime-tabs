{$} = require 'atom-space-pen-views'

TabBarView      = require './tabs/tab-bar-view'
SublimeTabView  = require './sublime-tab-view'

module.exports =
class SublimeTabBarView extends TabBarView

  initialize: (@pane) ->

    # During initialization we do not add temporary tabs. This prevents bugs
    # associated with serialization.
    @considerTemp = false

    super(@pane)
    @openPermanent ?= []

    $(window).on 'window:open-path', (event, {pathToOpen}) =>
      path = atom.project?.relativize(pathToOpen) ? pathToOpen
      @openPermanent.push pathToOpen unless pathToOpen in @openPermanent


    $(atom.views.getView(atom.workspace)).on 'core:save', ->
        tab = atom.workspaceView.find('.tab.active')
        tab.removeClass('temp') if tab.is('.temp')

    # Tabs added manually by the user should consider temporary status.
    @considerTemp = true

    @on 'dblclick', '.tab', ({target}) ->
      tab = $(target).closest('.tab').view()
      tab.removeClass('temp') if tab.is('.temp')
      false

  addTabForItem: (item, index) ->
    if item.uri != "atom://config"
        for tab in @getTabs()
          @closeTab(tab) if tab.is('.temp')

    tabView = new SublimeTabView(item, @pane, @openPermanent, @considerTemp)
    @insertTabAtIndex(tabView, index)
    @updateActiveTab()
