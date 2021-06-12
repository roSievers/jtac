

"""
Model wrapper that enables game state caching. This wrapper is intended for
accelerating MCTS playouts, since previously evaluated game states might be
queried repeatedly.
"""
mutable struct Caching{G} <: AbstractModel{G, false}
  model :: AbstractModel{G}
  max_cachesize :: Int
  cache :: Dict{UInt64, Tuple{Float32, Vector{Float32}}}
  calls_cached :: Int
  calls_uncached :: Int
end

"""
    Caching(model; max_cachesize)

Wraps `model` in a caching layer that checks if a game to be evaluated has
already been cached. If so, the cached result is reused. If it has not been
cached before, and if fewer game states that `max_cachesize` are currently
stored, it is added to the cache.
"""
function Caching(model :: AbstractModel; max_cachesize = 100000)
  cache = Dict{UInt64, Tuple{Float32, Vector{Float32}}}()
  sizehint!(cache, max_cachesize)
  Caching(model, max_cachesize, cache, 0, 0)
end

function (m :: Caching{G})(game :: G, use_features = false) where {G <: AbstractGame}
  @assert !use_features "Features cannot be used in Caching models"
  m.calls_cached += 1
  r = get(m.cache, Game.hash(game)) do
    m.calls_cached -= 1
    m.calls_uncached += 1
    res = m.model(game)[1:2]
    if length(m.cache) < m.max_cachesize
      m.cache[Game.hash(game)] = res
    end
    res
  end
  (r..., Float32[])
end

function (m :: Caching{G})( games :: Vector{G}
                          , use_features = false
                          ) where {G <: AbstractGame}

  @assert !use_features "Features cannot be used in Caching models. "
  @warn "Calling Caching models in batched mode is not recommended." maxlog=1

  outputs = map(x -> m(x, use_features), games)
  cat_outputs(outputs)
end

function clear_cache!(m :: Caching{G}) where {G <: AbstractGame}
  m.cache = Dict{UInt64, Tuple{Float32, Vector{Float32}}}()
  sizehint!(m.cache, m.max_cachesize)
  m.calls_cached = 0
  m.calls_uncached = 0
  nothing
end

function switch_model(m :: Caching{G}, model :: AbstractModel{G}) where {G <: AbstractGame}
  Caching(model; max_cachesize = m.max_cachesize)
end

swap(m :: Caching) = @warn "Caching models cannot be swapped"
Base.copy(m :: Caching) = switch_model(m, copy(m.model))

ntasks(m :: Caching) = ntasks(m.model)
base_model(m :: Caching) = base_model(m.model)
training_model(m :: Caching) = training_model(m.model)

is_async(m :: Caching) = is_async(m.model)

features(m :: Caching) = Feature[]

function Base.show(io :: IO, m :: Caching{G}) where {G <: AbstractGame}
  print(io, "Caching($(length(m.cache)), $(m.max_cachesize), ")
  show(io, m.model)
  print(io, ")")
end

function Base.show(io :: IO, mime :: MIME"text/plain", m :: Caching{G}) where {G <: AbstractGame}
  print(io, "Caching($(length(m.cache)), $(m.max_cachesize)) ")
  show(io, mime, m.model)
end



