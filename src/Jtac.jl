# Jtac.jl
# A julia implementation of the Alpha zero learning design

module Jtac

# We use machine learning capabilities of the package Knet.jl

import AutoGrad
import Knet
import Knet: identity, relu, softmax 

export AutoGrad, Knet, identity, relu, elu, softmax, tanh, sigm

# We save models/games via BSON.jl

import BSON

# We need functions in Random

import Random

# Interface that games must satisfy and some convenience functions

include("game.jl")
export Game, Status, ActionIndex,
       status, current_player, legal_actions, apply_action!, 
       is_action_legal, representation, policy_length, random_playout, 
       augment, draw, is_over, random_turn!


# Interface for models

include("model.jl")
export Model, apply, save_model, load_model, 
       to_gpu, to_cpu, swap, on_gpu, training_model

# Building blocks for models

include("layers.jl")
export Dense, Conv, Deconv, Pool, Chain, Dropout, Batchnorm, 
       valid_insize, outsize, @chain

# Model implementations

include("models/toy.jl")
export DummyModel, RandomModel, RolloutModel

include("models/base.jl")
export BaseModel, Shallow, MLP, ShallowConv

include("models/async.jl")
export Async

# Markov chain tree search with model predictions

include("mc.jl")
export mctree_turn!

# Game implementations

include("games/tictactoe.jl")
include("games/metatac.jl")
export TicTacToe, MetaTac

# Loss and update steps for learning

include("learning.jl")
export DataSet, loss, record_selfplay, 
       set_optimizer!, train_step!,
       minibatch # exports Knet.minibatch

# Players

include("player.jl")
export RandomPlayer, MCTPlayer, 
       IntuitionPlayer, HumanPlayer, 
       pvp

end # module JTac
