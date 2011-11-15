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
  drawNoteText(ctx, pt.x, pt.y, obj.body)

drawNoteText = (ctx, x, y, body) ->
  ctx.fillStyle = "rgb(230, 230, 240)"
  ctx.fillRect(x, y + 3, ctx.measureText(body).width, 10)
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
  drawMessageText(ctx, bodyPt.x, bodyPt.y, obj.body)

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
  drawMessageText(ctx, bodyPt.x, bodyPt.y, obj.body)

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

drawMessageText = (ctx, x, y, body) ->
  width = ctx.measureText(body).width
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
  $("textarea#source_text").focus()
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
  canvas.height = calcCanvasHeight(messages)
  ctx.font = "12px Sans-Serif"
  canvas.width = calcCanvasWidth(ctx, instances)
  fillBackground(ctx, canvas.width, canvas.height)
  drawInstances(ctx, instances, canvas.height - MESSSAGE_OFFSET - CANVAS_PADDING)
  drawMessages(ctx, messages)
  disableOpenImageButton(false)

addRectToInstances = (ctx, instances, messages) ->
  first = _.min(instances, (obj) -> obj.order)
  x = CANVAS_PADDING + getInstanceMargin(ctx, instances, messages, first)
  for obj in instances
    obj.rect = createInstanceRect(ctx, x, obj)
    x += Math.round(obj.rect.width + INSTANCE_OFFSET)

getInstanceMargin = (ctx, instances, messages, instance) ->
  return 0 unless instance?
  
  # TODO noteBodyMargin
  normalBodyMargin = getMaxNormalBodyMargin(ctx, instance)
  selfBodyMargin = getMaxSelfBodyMargin(ctx, instance)
  bodyMargin = Math.max(normalBodyMargin, selfBodyMargin)
  
  nameWidth1 = roundInstanceWidth(ctx, instance.name)
  nameMargin = nameWidth1 / 2
  gap = Math.round(bodyMargin - nameMargin)
  return gap if gap > 0
  
  return 0

getMaxSelfBodyMargin = (ctx, instance) ->
  message = _.max(messages, (obj) -> getRelatedSelfBodyWidth(ctx, instance, obj))
  return 0 unless isValidMessage(message)
  return 0 unless isSelfMessage(message)
  return 0 if isNote(message)
  return 0 unless message.from is instance
  
  bodyWidth = ctx.measureText(message.body).width
  return bodyWidth / 2

getRelatedSelfBodyWidth = (ctx, instance, message) ->
  return 0 unless message.from is instance
  return 0 unless isSelfMessage(message)
  
  bodyWidth = ctx.measureText(message.body).width
  return bodyWidth / 2

getMaxNormalBodyMargin = (ctx, instance1) ->
  message = _.max(messages, (obj) -> getRelatedBodyWidth(ctx, instance1, obj))
  return 0 unless isValidMessage(message)
  
  instance2 = message.to
  return 0 unless instance2?
  
  nameWidth1 = roundInstanceWidth(ctx, instance1.name)
  nameWidth2 = roundInstanceWidth(ctx, instance2.name)
  
  distance = nameWidth1 / 2 + nameWidth2 / 2 + INSTANCE_OFFSET
  bodyWidth = ctx.measureText(message.body).width
  return bodyWidth / 2 - distance / 2

getRelatedBodyWidth = (ctx, instance1, message) ->
  return 0 if isSelfMessage(message)
  
  if message.from is instance1
    instance2 = message.to
  else if message.to is instance1
    instance2 = message.from
  else
    return 0
  return 0 unless instance2?
  
  nameWidth1 = roundInstanceWidth(ctx, instance1.name)
  nameWidth2 = roundInstanceWidth(ctx, instance2.name)
  
  distance = nameWidth1 / 2 + nameWidth2 / 2 + INSTANCE_OFFSET
  bodyWidth = ctx.measureText(message.body).width
  return bodyWidth

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
  obj.rect = rect

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

calcCanvasHeight = (messages) ->
  last = _.max(messages, (obj) -> obj.order)
  return unless last?
  height = INSTANCE_HEIGHT + MESSSAGE_OFFSET * (last.order + 2)
  height += CANVAS_PADDING * 2
  return height

calcCanvasWidth = (ctx, instances) ->
  last = _.max(instances, (obj) -> obj.order)
  return unless last?
  x = getInstanceMargin(ctx, instances, messages, last)
  width = CANVAS_PADDING * 2 + last.rect.x + last.rect.width + x
  return width

fillBackground = (ctx, width, height) ->
  ctx.fillStyle = "white"
  ctx.fillRect(0, 0, width, height)
  ctx.fillStyle = "black"

# ------------------------------

disableOpenImageButton = (flag) ->
  button = $("input#open_button")[0]
  button.disabled = flag

this.openImage = ->
  canvas = $('#diagram')[0]
  return unless canvas
  window.open(canvas.toDataURL("image/png"))
  return

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
  disableOpenImageButton(true)
  
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
