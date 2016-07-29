#!/bin/bash

curl -H "Content-Type: application/json" -X POST -d '{ "msg": "Can you help me, please?" }' http://localhost:8080/ncchat

# It should return {"response":"I think so, daughter.","id":1}
