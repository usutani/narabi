MESSSAGE_OFFSET = 40
MESSSAGE_BODY_OFFSET = -18
MESSSAGE_SELF_WIDTH = 28
MESSSAGE_SELF_HEIGHT = 17
MESSSAGE_ARROW_WIDTH = 5
MESSSAGE_ARROW_HEIGHT = -8

INSTANCE_OFFSET = 40
INSTANCE_PADDING = 10
INSTANCE_WIDTH = 70
INSTANCE_HEIGHT = 30

CANVAS_PADDING = 15

fillBackground = (ctx, width, height) ->
  ctx.fillStyle = "white"
  ctx.fillRect(0, 0, width, height)
  ctx.fillStyle = "black"

drawMessages = (ctx, messages) ->
  drawMessage(ctx, obj) for obj in messages

drawMessage = (ctx, obj) ->
  return unless checkPresenceOfToFromObjects(obj)
  if isNote(obj)
    drawNote(ctx, obj)
  else if isSelfMessage(obj)
    drawSelfMessageLine(ctx, obj)
  else
    drawNormalMessageLine(ctx, obj)

drawNote = (ctx, obj) ->
  pt = obj.note.bodyPoint
  drawNoteText(ctx, pt.x, pt.y, obj.rect.bodyWidth, obj.body)

drawNoteText = (ctx, x, y, width, body) ->
  ctx.fillStyle = "rgb(230, 230, 240)"
  ctx.fillRect(x, y + 3, width, 10)
  ctx.fillStyle = "black"

  ctx.font = "12px Sans-Serif"
  ctx.textAlign = "left"
  ctx.textBaseline = "top"
  ctx.fillText(body, x, y)

checkPresenceOfToFromObjects = (obj) ->
  return false unless obj.from?
  return false unless obj.to?
  return true

isValidMessage = (message) ->
  return false unless message?
  return false unless checkPresenceOfToFromObjects(message)
  return true

isSelfMessage = (obj) -> return obj.to is obj.from

isNote = (obj) -> return obj.is_note

drawSelfMessageLine = (ctx, obj) ->
  headPt = obj.selfMessage.headPoint
  bodyPt = obj.selfMessage.bodyPoint
  drawSelfMessagePath(ctx, obj.selfMessage.rect)
  drawMessageArrowhead(ctx, headPt, true)
  drawMessageText(ctx, bodyPt.x, bodyPt.y, obj.rect.bodyWidth, obj.body)

drawSelfMessagePath = (ctx, rect) ->
  ctx.beginPath()
  ctx.moveTo(rect.x1, rect.y1)
  ctx.lineTo(rect.x2, rect.y1)
  ctx.lineTo(rect.x2, rect.y2)
  ctx.lineTo(rect.x1, rect.y2)
  ctx.closePath()
  ctx.stroke()

drawNormalMessageLine = (ctx, obj) ->
  headPt = obj.normalMessage.headPoint
  bodyPt = obj.normalMessage.bodyPoint
  drawMessageLine(ctx, obj.rect, obj.is_return)
  drawMessageArrowhead(ctx, headPt, isHeadLeft(obj))
  drawMessageText(ctx, bodyPt.x, bodyPt.y, obj.rect.bodyWidth, obj.body)

isHeadLeft = (obj) ->
  obj.to.order <= obj.from.order

drawMessageLine = (ctx, rect, isReturn) ->
  if isReturn
    ctx.drawDashedLine(rect.x1, rect.y1, rect.x2, rect.y1)
  else
    ctx.drawLine(rect.x1, rect.y1, rect.x2, rect.y1)

CanvasRenderingContext2D.prototype.drawDashedLine = (x1, y1, x2, y2) ->
  this.moveTo(x1, y1)
  dX = x2 - x1
  dY = y2 - y1
  dashes = Math.floor(Math.sqrt(dX * dX + dY * dY) / 4)
  dashX = dX / dashes
  dashY = dY / dashes
  q = 0
  while (q++ < dashes)
    x1 += dashX
    y1 += dashY
    if q % 2 == 0
      this.moveTo(x1, y1)
    else
      this.lineTo(x1, y1)

CanvasRenderingContext2D.prototype.drawLine = (x1, y1, x2, y2) ->
  this.beginPath()
  this.moveTo(x1, y1)
  this.lineTo(x2, y2)
  this.closePath()
  this.stroke()

drawMessageArrowhead = (ctx, pt, isHeadLeft) ->
  offsetX = MESSSAGE_ARROW_HEIGHT
  offsetX *= -1 if isHeadLeft
  ctx.lineCap = "square"
  ctx.lineJoin = "miter"
  ctx.moveTo(pt.x + offsetX, pt.y - MESSSAGE_ARROW_WIDTH)
  ctx.lineTo(pt.x, pt.y)
  ctx.lineTo(pt.x + offsetX, pt.y + MESSSAGE_ARROW_WIDTH)
  ctx.stroke()

drawMessageText = (ctx, x, y, width, body) ->
  ctx.fillStyle = "white"
  ctx.fillRect(x - width / 2, y , width, 12)
  ctx.fillStyle = "black"
  ctx.font = "12px Sans-Serif"
  ctx.textAlign = "center"
  ctx.textBaseline = "top"
  ctx.fillText(body, x, y)

# ------------------------------

drawInstances = (ctx, instances, bottom) ->
  for obj in instances
    drawInstanceRect(ctx, obj.rect)
    drawInstanceText(ctx, obj.rect, obj.name)
    drawInstanceLine(ctx, obj.rect, bottom)
  return

drawInstanceRect = (ctx, rect) ->
  ctx.strokeRect(rect.x, rect.y, rect.width, rect.height)

drawInstanceText = (ctx, rect, name) ->
  ctx.font = "12px Sans-Serif"
  ctx.textAlign = "center"
  ctx.textBaseline = "middle"
  ctx.fillText(name, rect.centerX, rect.centerY)

drawInstanceLine = (ctx, rect, bottom) ->
  ctx.beginPath()
  ctx.moveTo(rect.centerX, rect.y + rect.height)
  ctx.lineTo(rect.centerX, rect.centerY + bottom)
  ctx.closePath()
  ctx.stroke()

getInstanceRectByOrder = (instances, instanceOrder) ->
  obj = _.find(instances, (obj) -> obj.order is instanceOrder)
  return obj.rect

# ------------------------------

this.onload = ->
  disableSnippetButtons()
  $("#source_text").focus()
  setInfoText("Processing...")
  this.postRawText()

fetchRestObjects = (uri, callback) ->
  $.ajax({
    type: "GET",
    url: uri,
    dataType: "json",
    data: null,
    success: (data) -> 
      callback(data)
    })

instancesDidFetched = (data) ->
  window.instances = data
  fetchRestObjects("messages.json", messagesDidFetched)

messagesDidFetched = (data) ->
  window.messages = data
  setToFromObjects(instances, obj) for obj in window.messages
  drawObjects(window.instances, window.messages)
  setInfoText("")

setToFromObjects = (instances, message) ->
  message.to = _.find(instances, (obj) -> obj.id is message.to_id)
  message.from = _.find(instances, (obj) -> obj.id is message.from_id)

drawObjects = (instances, messages) ->
  canvas = $('#diagram')[0]
  return unless canvas
  if instances.length is 0
    canvas.wodth = 0
    canvas.height = 0
    return
  ctx = canvas.getContext("2d")
  ctx.font = "12px Sans-Serif"
  addRectToInstances(ctx, instances, messages)
  addRectToMessages(ctx, instances, messages)
  offset = getOffset(instances, messages)
  shiftRectsForMergin(offset.left, instances, messages)
  canvas.height = calcCanvasHeight(messages)
  canvas.width = offset.right
  fillBackground(ctx, canvas.width, canvas.height)
  drawInstances(ctx, instances, canvas.height - MESSSAGE_OFFSET - CANVAS_PADDING)
  drawMessages(ctx, messages)
  disableButtons(false)

# ------------------------------

addRectToInstances = (ctx, instances, messages) ->
  x = 0
  for obj in instances
    obj.rect = createInstanceRect(ctx, x, obj)
    x += Math.round(obj.rect.width + INSTANCE_OFFSET)

createInstanceRect = (ctx, x, obj) ->
  rect = new Object()
  rect.x = x
  rect.y = CANVAS_PADDING
  rect.width = roundInstanceWidth(ctx, obj.name)
  rect.height = INSTANCE_HEIGHT
  rect.centerX = Math.round(rect.x + rect.width / 2)
  rect.centerY = Math.round(rect.y + rect.height / 2)
  return rect

roundInstanceWidth = (ctx, name) ->
  nameWidth = ctx.measureText(name).width
  return Math.max(INSTANCE_WIDTH, nameWidth + INSTANCE_PADDING)

addRectToMessages = (ctx, instances, messages) ->
  for obj in messages
    if checkPresenceOfToFromObjects(obj)
      obj.rect = createMessageRect(ctx, instances, obj)
      if isNote(obj)
        obj.note = createNote(obj.rect)
      else if isSelfMessage(obj)
        obj.selfMessage = createSelfMessage(ctx, instances, obj)
      else
        obj.normalMessage = createNormalMessage(instances, obj)

createMessageRect = (ctx, instances, obj) ->
  rect = new Object()
  pt = createIntersectionPoint(instances, obj.from.order, obj.order)
  rect.x1 = pt.x
  rect.y1 = pt.y
  pt = createIntersectionPoint(instances, obj.to.order, obj.order)
  rect.x2 = pt.x
  rect.y2 = pt.y
  rect.centerX = getMiddlePos(rect.x1, rect.x2)
  rect.centerY = getMiddlePos(rect.y1, rect.y2)
  rect.bodyWidth = ctx.measureText(obj.body).width
  return rect

createIntersectionPoint = (instances, instanceOrder, messageOrder) ->
  result = new Object()
  rect = getInstanceRectByOrder(instances, instanceOrder)
  result.x = rect.centerX
  result.y = rect.y + rect.height + (messageOrder + 1) * MESSSAGE_OFFSET
  return result

getMiddlePos = (a, b) ->
  return a + (b - a) / 2

createNote = (rect) ->
  pt = new Object()
  pt.x = rect.centerX - INSTANCE_WIDTH / 2
  pt.y = rect.centerY
  note = new Object()
  note.bodyPoint = pt
  return note

createSelfMessage = (ctx, instances, obj) ->
  result = new Object()
  result.rect = createSelfMessageRect(ctx, instances, obj)
  result.headPoint = createSelfMessageHeadPoint(result.rect)
  result.bodyPoint = createSelfMessageBodyPoint(result.rect)
  return result

createSelfMessageRect = (ctx, instances, obj) ->
  result = new Object()
  pt = createIntersectionPoint(instances, obj.from.order, obj.order)
  result.x1 = pt.x
  result.y1 = pt.y
  result.x2 = pt.x + MESSSAGE_SELF_WIDTH
  result.y2 = pt.y + MESSSAGE_SELF_HEIGHT
  return result

createSelfMessageHeadPoint = (rect) ->
  pt = new Object()
  pt.x = rect.x1
  pt.y = rect.y2
  return pt

createSelfMessageBodyPoint = (rect) ->
  pt = new Object()
  pt.x = rect.x1
  pt.y = rect.y1 + MESSSAGE_BODY_OFFSET
  return pt

createMessageBodyPoint = (rect) ->
  pt = new Object()
  pt.x = rect.centerX
  pt.y = rect.centerY + MESSSAGE_BODY_OFFSET
  return pt

createNormalMessage = (instances, obj) ->
  result = new Object()
  result.headPoint = createIntersectionPoint(instances, obj.to.order, obj.order)
  result.bodyPoint = createMessageBodyPoint(obj.rect)
  return result

getOffset = (instances, messages) ->
  left = 0
  right = 0
  
  for obj in messages
    halfWidth = obj.rect.bodyWidth / 2
    left = Math.min(left, obj.rect.centerX - halfWidth) unless isNote(obj)
    if isNote(obj)
      iw =  obj.from.rect.width / 2
      right = Math.max(right, obj.rect.centerX + obj.rect.bodyWidth - iw)
    else
      right = Math.max(right, obj.rect.centerX + halfWidth)
  
  last = _.max(instances, (obj) -> obj.order)
  right = Math.max(right, last.rect.x + last.rect.width) if last?
  
  left = - Math.round(left - CANVAS_PADDING)
  right = Math.round(left + right + CANVAS_PADDING)
  return {left: left, right:right}

shiftRectsForMergin = (dx, instances, messages) ->
  shiftInstanceRects(instances, dx)
  shiftMessageRects(messages, dx)

shiftInstanceRects = (instances, dx) ->
  for obj in instances
    obj.rect.x += dx
    obj.rect.centerX += dx

shiftMessageRects = (messages, dx) ->
  for obj in messages
    obj.rect.x1 += dx
    obj.rect.x2 += dx
    obj.rect.centerX += dx
    if obj.note?
      obj.note.bodyPoint.x += dx
    if obj.selfMessage?
      obj.selfMessage.headPoint.x += dx
      obj.selfMessage.bodyPoint.x += dx
      obj.selfMessage.rect.x1 += dx
      obj.selfMessage.rect.x2 += dx
    if obj.normalMessage?
      obj.normalMessage.headPoint.x += dx
      obj.normalMessage.bodyPoint.x += dx

calcCanvasHeight = (messages) ->
  last = _.max(messages, (obj) -> obj.order)
  return unless last?
  height = INSTANCE_HEIGHT + MESSSAGE_OFFSET * (last.order + 2)
  height += CANVAS_PADDING * 2
  return height

# ------------------------------

disableButtons = (flag) ->
  button1 = $("input#open_button")[0]
  button1.disabled = flag

this.openImage = ->
  canvas = $('#diagram')[0]
  return unless canvas
  window.open(canvas.toDataURL("image/png"))

# ------------------------------

this.appendSnippet = (index) ->
  key = snippetIndex2key(index)
  text = localStorage.getItem(key)
  text ?= ""
  return if text.length is 0
  $("#source_text").val($("#source_text").val() + text)
  $("#source_text").focus()
  setInfoText("Processing...")
  this.postRawText()

this.saveSnippet = ->
  index = $('#snippet_no option:selected').val()
  key = snippetIndex2key(index)
  text = $("#source_text").val()
  if text.length is 0
    return unless window.confirm("Are you sure you want to empty snippet?")
    localStorage.removeItem(key)
    disableSnippetButton(key, true)
  else
    return unless window.confirm("Are you sure you want to save text to snippet?")
    localStorage.setItem(key, text)
    disableSnippetButton(key, false)

snippetIndex2key = (index) -> "snippet" + eval(index)

disableSnippetButtons = ->
  for i in [0..4]
    key = snippetIndex2key(i)
    text = localStorage.getItem(key)
    text ?= ""
    disableSnippetButton(key, text.length is 0)

disableSnippetButton = (key, flag) ->
  button = $("input#" + key)[0]
  button.disabled = flag

# ------------------------------

this.keydown = ->
  setInfoText("Processing...")
  clearTimeout(this.timerID)

this.keyup = ->
  clearTimeout(this.timerID)
  this.timerID = setTimeout("this.postRawText()", 1000)

this.postRawText = () ->
  text = "source_text=" + $("#source_text").val()
  if this.lastRawText is text
    setInfoText("")
    return
  disableButtons(true)
  
  $.ajax({
    type: "POST",
    url: "home/parse_text",
    data: text,
    success: (data) -> 
      fetchRestObjects("instances.json", instancesDidFetched)
    })
  this.lastRawText = text

setInfoText = (text) ->
  $("label#info_label").text(text)
