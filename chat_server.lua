#!/usr/bin/env th

require 'neuralconvo'
local tokenizer = require "tokenizer"
local list = require "pl.List"
local options = {}

--[[

A simple todo-list server example.

This example requires the restserver-xavante rock to run.

A fun example session:

curl localhost:8080/ncchat
curl -v -H "Content-Type: application/json" -X POST -d '{ "msg": "Can you help me, please?" }' http://localhost:8080/ncchat

]]

-- Data
dataset = neuralconvo.DataSet()

print("-- Loading model")
model = torch.load("data/model.t7")

-- Word IDs to sentence
function pred2sent(wordIds, i)
  local words = {}
  i = i or 1

  for _, wordId in ipairs(wordIds) do
    local word = dataset.id2word[wordId[i]]
    table.insert(words, word)
  end

  return tokenizer.join(words)
end

function printProbabilityTable(wordIds, probabilities, num)
  print(string.rep("-", num * 22))

  for p, wordId in ipairs(wordIds) do
    local line = "| "
    for i = 1, num do
      local word = dataset.id2word[wordId[i]]
      line = line .. string.format("%-10s(%4d%%)", word, probabilities[p][i] * 100) .. "  |  "
    end
    print(line)
  end

  print(string.rep("-", num * 22))
end

function say(text)
  local wordIds = {}

  for t, word in tokenizer.tokenize(text) do
    local id = dataset.word2id[word:lower()] or dataset.unknownToken
    table.insert(wordIds, id)
  end

  local input = torch.Tensor(list.reverse(wordIds))
  local wordIds, probabilities = model:eval(input)

  local output = pred2sent(wordIds)
  print("neuralconvo> " .. output)

  if options.debug then
    printProbabilityTable(wordIds, probabilities, 4)
  end

  return output
end


local restserver = require("restserver")
local server = restserver:new():port(8080)
local responses = {}
local next_id = 0

server:add_resource("ncchat", {
   {
      method = "POST",
      path = "/",
      consumes = "application/json",
      produces = "application/json",
      input_schema = {
         msg = { type = "string" },
      },
      handler = function(msg_submission)
         print("Received msg: " .. msg_submission.msg)
         next_id = next_id + 1
         msg_submission.response = say(msg_submission.msg)
         print("Response: " .. msg_submission.response)
         table.insert(responses, msg_submission)
         local result = {
            id = next_id
         }
         return restserver.response():status(200):entity(responses)
      end,
   }
   
})

-- This loads the restserver.xavante plugin
server:enable("restserver.xavante"):start()


