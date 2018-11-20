
# Base Model
# Wrapper around a model that generates 1 + policy_length "logit" values

struct BaseModel{GPU} <: Model{GPU}
  logitmodel :: Layer{GPU}  # Takes input and returns "logits"
  vconv                     # Converts value-logit to value
  pconv                     # Converts policy-logits to policy
end

function BaseModel(logitmodel; vconv = tanh, pconv = softmax)
  BaseModel(logitmodel, vconv, pconv)
end

function (m :: BaseModel{GPU})(games :: Vector{G}) where {GPU, G <: Game}
  at = atype(GPU)
  data = convert(at, representation(games))
  result = m.logitmodel(data)
  vcat(m.vconv.(result[1:1,:]), m.pconv(result[2:end,:], dims = 1))
end

(m :: BaseModel)(game :: Game) = reshape(m([game]), (policy_length(game) + 1,))


# Some generic models

# Linear Model
# A linear model that will perform terrible

function LinearModel(game :: Game; kwargs...)
  logitmodel = Dense(prod(size(game)), policy_length(game) + 1, id)
  BaseModel(logitmodel; kwargs...)
end

# Multilayer perception

function MLP(game :: Game, hidden, f = relu; kwargs...)
  widths = [ prod(size(game)), hidden..., policy_length(game) + 1 ]
  layers = [ Dense(widths[j], widths[j+1], f) for j in 1:length(widths) - 1 ]
  BaseModel(Chain(layers...); kwargs...)
end

# Very simple convolutional network

function SimpleConv(game :: Game, channels, f = relu; kwargs...)
  logitmodel = Chain(
    Conv(size(game, 3), channels, f),
    Dense(channels, policy_length(game) + 1, id)
  )
  BaseModel(logitmodel; kwargs...)
end