MESSSAGE_OFFSET = 40
MESSSAGE_BODY_OFFSET = -14
MESSSAGE_SELF_LENGTH = 23
MESSSAGE_ARROW_WIDTH = 5
MESSSAGE_ARROW_HEIGHT = -10

INSTANCE_OFFSET = 60
INSTANCE_WIDTH = 45
INSTANCE_HEIGHT = 30

CANVAS_PADDING = 15

drawMessages = (ctx, messages) ->
  drawMessage(ctx, obj) for obj in messages

drawMessage = (ctx, obj) ->
  return unless checkPresenceOfToFromObjects(obj)
  if isSelfMessage(obj)
    drawSelfMessageLine(ctx, obj)
  else
    drawNormalMessageLine(ctx, obj)

checkPresenceOfToFromObjects = (obj) ->
  return false unless obj.from?
  return false unless obj.to?
  return true

isSelfMessage = (obj) -> return obj.to is obj.from

drawSelfMessageLine = (ctx, obj) ->
  rect = getSelfMessageRect(ctx, obj)
  drawSelfMessagePath(ctx, rect)
  pt = getSelfMessageEndPoint(rect)
  drawMessageArrowhead(ctx, pt, true)
  pt = getSelfMessageBodyPoint(rect)
  drawMessageText(ctx, pt.x, pt.y, obj.body)

getSelfMessageEndPoint = (rect) ->
  pt = new Object()
  pt.x = rect.x1
  pt.y = rect.y2
  return pt

getSelfMessageBodyPoint = (rect) ->
  pt = new Object()
  pt.x = rect.x1
  pt.y = rect.y1 + MESSSAGE_BODY_OFFSET
  return pt

getSelfMessageRect = (ctx, obj) ->
  result = new Object()
  pt = getIntersectionPoint(obj.from.order, obj.order)
  result.x1 = pt.x
  result.y1 = pt.y
  result.x2 = pt.x + MESSSAGE_SELF_LENGTH
  result.y2 = pt.y + MESSSAGE_SELF_LENGTH
  return result

drawSelfMessagePath = (ctx, rect) ->
  ctx.beginPath()
  ctx.moveTo(rect.x1, rect.y1)
  ctx.lineTo(rect.x2, rect.y1)
  ctx.lineTo(rect.x2, rect.y2)
  ctx.lineTo(rect.x1, rect.y2)
  ctx.closePath()
  ctx.stroke()

drawNormalMessageLine = (ctx, obj) ->
  rect = getMessageRect(ctx, obj)
  drawMessageLine(ctx, rect, obj.is_return)
  pt = getIntersectionPoint(obj.to.order, obj.order)
  drawMessageArrowhead(ctx, pt, isHeadLeft(obj))
  pt = getMessageBodyPoint(rect)
  drawMessageText(ctx, pt.x, pt.y, obj.body)

getMessageBodyPoint = (rect) ->
  pt = new Object()
  pt.x = rect.centerX
  pt.y = rect.centerY + MESSSAGE_BODY_OFFSET
  return pt

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
  ctx.moveTo(pt.x + offsetX, pt.y - MESSSAGE_ARROW_WIDTH)
  ctx.lineTo(pt.x, pt.y)
  ctx.lineTo(pt.x + offsetX, pt.y + MESSSAGE_ARROW_WIDTH)
  ctx.stroke()

drawMessageText = (ctx, x, y, body) ->
  ctx.font = "12px Sans-Serif"
  ctx.textAlign = "center"
  ctx.textBaseline = "top"
  ctx.fillText(body, x, y)

getMessageRect = (ctx, obj) ->
  result = new Object()
  pt = getIntersectionPoint(obj.from.order, obj.order)
  result.x1 = pt.x
  result.y1 = pt.y
  pt = getIntersectionPoint(obj.to.order, obj.order)
  result.x2 = pt.x
  result.y2 = pt.y
  result.centerX = getMiddlePos(result.x1, result.x2)
  result.centerY = getMiddlePos(result.y1, result.y2)
  return result

getMiddlePos = (a, b) ->
  return a + (b - a) / 2

getIntersectionPoint = (instanceOrder, messageOrder) ->
  result = new Object()
  rect = getInstanceRect(instanceOrder)
  result.x = rect.centerX
  result.y = rect.y + rect.height + (messageOrder + 1) * MESSSAGE_OFFSET
  return result

# ------------------------------

drawInstances = (ctx, instances, bottom) ->
  drawInstance(ctx, obj, bottom) for obj in instances

drawInstance = (ctx, obj, bottom) ->
  rect = getInstanceRect(obj.order)
  drawInstanceRect(ctx, rect)
  drawInstanceText(ctx, rect, obj.name)
  drawInstanceLine(ctx, rect, bottom)

getInstanceRect = (order) ->
  result = new Object()
  result.x = order * (INSTANCE_WIDTH + INSTANCE_OFFSET) + CANVAS_PADDING
  result.y = 0 + CANVAS_PADDING
  result.width = INSTANCE_WIDTH
  result.height = INSTANCE_HEIGHT
  result.centerX = result.x + result.width / 2
  result.centerY = result.y + result.height / 2
  return result

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

# ------------------------------

this.onload = ->
  fetchRestObjects("instances.json", instancesDidFetched)

fetchRestObjects = (uri, callback) ->
  xhr = new (window.ActiveXObject or XMLHttpRequest)("Microsoft.XMLHTTP")
  xhr.open "GET", uri, true
  xhr.overrideMimeType "text/plain" if "overrideMimeType" of xhr
  xhr.onreadystatechange = ->
    if xhr.readyState is 4
      if xhr.status in [0, 200]
        callback(xhr)
      else
        throw new Error "Could not load #{url}"
  xhr.send null

instancesDidFetched = (xhr) ->
  window.instances = eval("(" + xhr.responseText + ")")
  fetchRestObjects("messages.json", messagesDidFetched)

messagesDidFetched = (xhr) ->
  window.messages = eval("(" + xhr.responseText + ")")
  setToFromObjects(instances, obj) for obj in window.messages
  drawObjects(window.instances, window.messages)

setToFromObjects = (instances, message) ->
  message.to = _.find(instances, (obj) -> obj.id is message.to_id)
  message.from = _.find(instances, (obj) -> obj.id is message.from_id)

drawObjects = (instances, messages) ->
  canvas = document.getElementById("diagram")
  return unless canvas
  canvas.height = calcCanvasHeight(messages)
  canvas.width = calcCanvasWidth(instances)
  ctx = canvas.getContext("2d")
  fillBackground(ctx, canvas.width, canvas.height)
  drawInstances(ctx, instances, canvas.height - MESSSAGE_OFFSET - CANVAS_PADDING)
  drawMessages(ctx, messages)

calcCanvasHeight = (messages) ->
  last = _.max(messages, (obj) -> obj.order)
  height = INSTANCE_HEIGHT + MESSSAGE_OFFSET * (last.order + 2)
  height += CANVAS_PADDING * 2
  return height

calcCanvasWidth = (instances) ->
  width = instances.length * (INSTANCE_WIDTH + INSTANCE_OFFSET)
  width -= INSTANCE_OFFSET
  width += CANVAS_PADDING * 2
  return width

fillBackground = (ctx, width, height) ->
  ctx.fillStyle = "white"
  ctx.fillRect(0, 0, width, height)
  ctx.fillStyle = "black"

# ------------------------------

this.openImage = ->
  canvas = document.getElementById("diagram")
  return unless canvas
  window.open(canvas.toDataURL("image/png"))
  return
