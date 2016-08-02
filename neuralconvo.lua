require 'torch'
require 'nn'
require 'rnn'

neuralconvo = {}

torch.include('neuralconvo', 'cornell_movie_dialogs.lua')
-- torch.include('neuralconvo', 'cornell_movie_dialogs_doctor.lua')
torch.include('neuralconvo', 'dataset.lua')
torch.include('neuralconvo', 'seq2seq.lua')

return neuralconvo
