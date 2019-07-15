local internal = require('internal')
local util = require('util')
local exports = {}
local elementRenderQueueStack

-- Rendering phase control

exports.isRendering = function()
    return elementRenderQueueStack ~= nil
end

local function assertRendering()
    assert(exports.isRendering(), 'Rendering not started or it has been aborted, cannot render an element.')
end

exports.render = function()
    assert(not exports.isRendering(), 'Rendering already started, invalid call to `gui.render()`.')

    elementRenderQueueStack = util.Stack.new({})
    _G.onRender()

    -- process render queue if rendering has not been aborted
    if exports.isRendering() then
        internal.processElementRenderQueue(elementRenderQueueStack:list()[1])
    end

    elementRenderQueueStack = nil
end

exports.abortRendering = function()
    assertRendering()
    elementRenderQueueStack = nil
end


-- Element rendering

-- TODO: Consider adding a way to record elements to a user-specified buffer and then commit them to the render queue together
function renderElement(userContent, elementType, content, ...)
    assert(type(elementType) == 'string')
    assertRendering()

    local elementRenderQueue = elementRenderQueueStack.peek(elementRenderQueueStack, 1)
    local element = {
        type = elementType,
        content = util.mergeTables(content, util.validateArguments(userContent, ...)),
    }

    table.insert(elementRenderQueue, element)

    return element
end

exports.openGroup = function(args)
    local element = renderElement(args,
        'group',
        { children = {} },
        { name = 'gravity',                      required = false }, -- may be either a string or a table of strings
        { name = 'width',                        required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'height',                       required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'weight',                       required = false }, -- a floating point number
        { name = 'horizontal', type = 'boolean', required = false }
    )
    elementRenderQueueStack:push(element.content.children)
end

exports.closeGroup = function(_)
    assertRendering()
    assert(elementRenderQueueStack:len() > 1, 'Cannot close group, since no group is currently open.')
    elementRenderQueueStack:pop()
end

exports.renderText = function(args)
    renderElement(args,
        'text',
        {},
        { name = 'gravity',                  required = false }, -- may be either a string or a table of strings
        { name = 'width',                    required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'height',                   required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'weight',                   required = false }, -- a floating point number
        { name = 'text',    type = 'string'                   }
    )
end

exports.renderImage = function(args)
    renderElement(args,
        'image',
        {},
        { name = 'width',                   required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'height',                  required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'weight',                  required = false }, -- a floating point number
        { name = 'path',   type = 'string'                   }
    )
end

exports.renderButton = function(args)
    renderElement(args,
        'button',
        {},
        { name = 'gravity',                    required = false }, -- may be either a string or a table of strings
        { name = 'width',                      required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'height',                     required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'weight',                     required = false }, -- a floating point number
        { name = 'text',    type = 'string'                     },
        { name = 'handler', type = 'function'                   }
    )
end

exports.renderTransitionButton = function(args)
    renderElement(args,
        'transitionButton',
        {},
        { name = 'gravity',                    required = false }, -- may be either a string or a table of strings
        { name = 'width',                      required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'height',                     required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'weight',                     required = false }, -- a floating point number
        { name = 'text',    type = 'string'                     },
        { name = 'subtext', type = 'string',   required = false },
        { name = 'handler', type = 'function'                   }
    )
end

exports.renderCheckBox = function(args)
    renderElement(args,
        'checkBox',
        {},
        { name = 'gravity',                    required = false }, -- may be either a string or a table of strings
        { name = 'width',                      required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'height',                     required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'weight',                     required = false }, -- a floating point number
        { name = 'text',    type = 'string',   required = false },
        { name = 'handler', type = 'function'                   }
    )
end

exports.renderTextInput = function(args)
    renderElement(args,
        'textInput',
        {},
        { name = 'gravity',                        required = false }, -- may be either a string or a table of strings
        { name = 'width',                          required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'height',                         required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'weight',                         required = false }, -- a floating point number
        { name = 'text',        type = 'string',   required = false },
        { name = 'placeholder', type = 'string',   required = false },
        { name = 'inputType',                      required = false },
        { name = 'handler',     type = 'function'                   }
    )
end

exports.renderNumberPicker = function(args)
    renderElement(args,
        'numberPicker',
        {},
        { name = 'gravity',                     required = false }, -- may be either a string or a table of strings
        { name = 'width',                       required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'height',                      required = false }, -- an integer, 'matchParent' or 'wrapContent'
        { name = 'weight',                      required = false }, -- a floating point number
        { name = 'value',    type = 'number',   required = false },
        { name = 'minValue', type = 'number',   required = false },
        { name = 'maxValue', type = 'number',   required = false },
        { name = 'handler',  type = 'function'                   }
    )
end


return exports
