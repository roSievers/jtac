# Jtac.jl
# A julia implementation of the Alpha zero learning design

module Jtac

# We use machine learning capabilities of the package Knet.jl
using AutoGrad, Knet

# Interface that games must satisfy and some convenience functions
include("game.jl")
export Game, Status, ActionIndex,
       status, current_player, legal_actions, apply_action!, 
       representation, policy_length, random_playout, draw


# Interface for models
include("model.jl")
export Model, apply

# Model building blocks 
include("models/layers.jl")
export Dense, Conv, Chain, id

# Model implementations
include("models/toymodels.jl")
export DummyModel, RandomModel, RolloutModel

include("models/genericmodels.jl")
export GenericModel, LinearModel, MLP, SimpleConv

# Markov chain tree search with model predictions
include("mc.jl")
export mctree_turn!, mctree_vs_random

# Game implementations
include("games/metatac.jl")
include("games/tictactoe.jl")
#include("games/four3d.jl")
#include("games/chess.jl")
export MetaTac, TicTacToe #, Four3d, Chess

# Loss for learning
include("learning.jl")
export DataSet, loss, record_selfplay

# Players
include("player.jl")
export RandomPlayer, MCTPlayer, 
       PolicyPlayer, SoftPolicyPlayer, 
       HumanPlayer, pvp

end # module JTac
