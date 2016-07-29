#!/bin/bash

cd /root/neuralconvo
nohup th train.lua --dataset 10000 --hiddenSize 500 &
