# Jtac.jl
# A julia implementation of the Alpha zero learning design

# Interface that games must satisfy and some convenience functions
include("game.jl")
export Game, Status, ActionIndex

# Interface for models
include("model.jl")
export Model

# Model implementations
include("models/toymodels.jl")
export DummyModel, RolloutModel, LinearModel

# Markov chain tree search with model predictions
include("mc.jl")
export mctree_turn!, mctree_vs_random

# Game implementations
include("games/metatac.jl")
#include("games/tac.jl")
#include("games/four3d.jl")
#include("games/chess.jl")
export MetaTac #, Tac, Four3d, Chess


