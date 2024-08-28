using CitableBase, CitableText, CitableCorpus
using Orthography, LatinOrthography
using StatsBase, OrderedCollections

repo = pwd()

f = joinpath(repo, "cex-editions", "lxxglosses.cex")
corpus = fromcex(f, CitableTextCorpus, FileReader)

"""Compile frequency table of lexical tokens.
Reduce ambiguous orthography to equivalent of Latin 23
by changing v/j to u/i.
"""
function freqs(c::CitableTextCorpus; ortho = latin25())
    lex = filter(tokenize(corpus, latin25())) do tkn
        tokencategory(tkn) isa LexicalToken
    end

    tokenvalues = map(t -> lowercase(tokentext(t)), lex) 
    reduced = map(tokenvalues) do s
        s1 = replace(s, "v" => "u")
        replace(s1, "j" => "i")
    end

    counts = countmap(reduced) |> OrderedDict
    sort!(counts; rev = true, byvalue = true)
end

countdict = freqs(corpus)

freqtable = []
for k in keys(countdict)
    push!(freqtable, string(k,"\t",countdict[k]))
end

open("freqs.tsv","w") do io
    write(io, join(freqtable,"\n"))
end