import telebot, asyncdispatch, logging, options
from strutils import strip
import httpClient
from xmltree import `$`,innerText, attr, attrs
from htmlparser import parseHtml
from streams import newStringStream
import strformat
import nimquery
import threadpool
import os

type
   ThreadData = tuple[command: string, chatId: int64]

var chatChan: Channel[ThreadData]
open(chatChan)

var L = newConsoleLogger(fmtStr="$levelname, [$time] ")
addHandler(L)

const API_KEY = slurp("secret.key").strip()

proc sendUpdate(b: Telebot) =
  var command = ""
  var chatId: int64

  while command != "stop":
    let (available, message) = chatChan.tryRecv()
    if available:
      command = message.command
      chatId = message.chatId
      echo "\n\n Recived message: " & command
    if command == "start":
      echo "Sending message: +++++++++++++++\n"
      echo "Chat id:",chatId
      discard waitFor b.sendMessage(chatId, "============================", disableNotification = true)
    sleep(3000)


proc updateHandler(b: Telebot, u: Update): Future[bool] {.async.} =
  if not u.message:
    return true
  var response = u.message.get
  if response.text:
    let text = response.text.get
    discard await b.sendMessage(response.chat.id, text, parseMode = "markdown", disableNotification = true, replyToMessageId = response.messageId)

proc greatingHandler(b: Telebot, c: Command): Future[bool] {.async,gcsafe.} =
  discard b.sendMessage(c.message.chat.id, "hello " & c.message.fromUser.get().firstname, disableNotification = true)
  result = true

proc startHandler(b: Telebot, c: Command): Future[bool] {.async,gcsafe.} =
  discard b.sendMessage(c.message.chat.id, c.message.fromUser.get().firstname & " we are starting now ....\n", disableNotification = true, replyToMessageId = c.message.messageId)
  chatChan.send((command:"start", chatId:c.message.chat.id))
  result = true

proc buyHandler(b: Telebot, c: Command): Future[bool] {.async.} =
  discard b.sendMessage(c.message.chat.id, "goodbuy " & c.message.fromUser.get().firstname, disableNotification = true, replyToMessageId = c.message.messageId)
  chatChan.send((command:"stop", chatId:c.message.chat.id))
  result = true

proc parceGad(zip:string, house:string, letter:string):string =
  var client = newHttpClient()

  let webpage= client.getContent(fmt("https://inzamelkalender.gad.nl/adres/{zip}:{house}:{letter}"))
  #echo webpage

  let xml          = parseHtml(newStringStream(webpage))
  let dates        = xml.querySelectorAll("ul#ophaaldata li a i.date")
  let garbageTypes = xml.querySelectorAll("ul#ophaaldata li a i:not(.date)")
  var reply = ""
  echo dates[0]
  for i in 0..<len(dates):
    reply = reply
    reply = reply & "" & innerText(dates[i]) & "* "
    reply = reply & innerText(garbageTypes[i]) & "\n"
  result=reply

proc gadHandler(b: Telebot, c: Command): Future[bool] {.async.} =
  discard b.sendMessage(c.message.chat.id, parceGad("1211HP", "6", "A"), parseMode="markdown", disableNotification = true, replyToMessageId = c.message.messageId)
  result = true

proc calHandler(b: Telebot, c: Command): Future[bool] {.async.} =
  discard b.sendDocument(c.message.chat.id, document="file:///home/watchcat/fun/gad_nl_bot/gad.ics", caption="gad.ics", disableNotification = true, replyToMessageId = c.message.messageId)
  result = true

when isMainModule:
  let bot = newTeleBot(API_KEY)
  bot.onUpdate(updateHandler)
  bot.onCommand("hello", greatingHandler)
  bot.onCommand("buy", buyHandler)
  bot.onCommand("start", startHandler)
  bot.onCommand("gad", gadHandler)
  bot.onCommand("cal", calHandler)
  spawn sendUpdate(bot)
  bot.poll(timeout=300)
