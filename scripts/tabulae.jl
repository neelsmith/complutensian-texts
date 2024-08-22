# Build parser from Tabulae cloned in adjacent directory

repo = joinpath(dirname(pwd()), "Tabulae.jl")


inflcommon = joinpath(repo, "datasets", "core-infl-shared")
infl25 = joinpath(repo, "datasets", "core-infl-lat25")
vocabcommon = joinpath(repo, "datasets", "cove-vocab-shared")
vocab25 = joinpath(repo, "datasets", "cove-vocab-lat25")


using Tabulae, CitableParserBuilder

tds = Tabulae.Dataset([
    inflcommon, infl25,
    vocabcommon, vocab25
])

p = tabulaeStringParser(tds)

parsetoken("", p)