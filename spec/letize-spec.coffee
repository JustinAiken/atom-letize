Letize = require '../lib/letize'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Letize", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement  = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('letize')

  describe "when the letize:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'letize:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        atom.commands.dispatch workspaceElement, 'letize:toggle'
