using OpenScripturesHebrew
using CitableText
using StatsBase, OrderedCollections

repo = pwd()


## OSHB data
oshbdatafile = joinpath(repo,"data", "hebrew","oshb","Gen.xml")
oshbgenesis = compilebook(oshbdatafile)

oshbgenesisverbs = filter(w -> isverb(w), oshbgenesis)
function compilelabeldict(oshbwords)
    pairs = []
    oshblemmata = map(t -> t.lemma, oshbwords) |> unique
    for t in oshblemmata
        entries = filter(otuple -> otuple.lemma == t,oshbgenesis) 
        forms = map(otuple -> otuple.mtoken, entries) |> unique
        max = length(forms) > 5 ? 5 : length(forms)
        labelval = join(forms[1:max], ", ")
        push!(pairs, (lemma = t, label = labelval))
    end
    pairs
end


@time labelsdict = compilelabeldict(oshbgenesis)

function isolatesoshbfiles(oshbdata, dict = labelsdict)
 
    tuples = []
    for tpl in oshbdata
        lemmstring = string(tpl.lemma)

        labelpairs = filter(pr -> pr.lemma == lemmstring, dict)
        labelval = isempty(labelpairs) ? lemmstring : labelpairs[1].label
        push!(tuples, (ref = tpl.urn, lexeme = lemmstring, label = labelval))
    end
    tuples
end

oshbconc = isolatesoshbfiles(oshbgenesisverbs)

septfile = joinpath(repo, "data", "greek", "greekverbs.cex")
septconc = map(readlines(septfile)[2:end]) do ln
    (ref, lemma, label) = split(ln, "|")
    (ref = ref, lexeme = lemma, label = label)
end

septgenesis = filter(t -> startswith(t.ref, "genesis:"), septconc)


vulgatefile = joinpath(repo, "data", "latin", "latinverbs.cex")
latinconc = map(readlines(vulgatefile)[2:end]) do ln
    (ref, lemma, label) = split(ln, "|")
    (ref = ref, lexeme = lemma, label = label)
end

vulgategenesis = filter(t -> startswith(t.ref, "genesis:"), latinconc)


## Sefaria data:
#=
sefariadatafile = joinpath(repo, "data", "hebrew", "sefariaverbs.cex")
sefariadata = readlines(sefariadatafile)[2:end]
filter(ln -> startswith(ln, "genesis:"), data)
=#



function cooccurs(tuples1, tuples2; messageinterval = 5)
    masterdict = Dict()
    lemmalist = map(t -> string(t.lexeme), tuples1)
    uniquelemms = unique(lemmalist)
    lemmalabel = ""

    @info("Counting cooccurrences for $(length(uniquelemms)) lexemes")
    count = 0
    for lemm in uniquelemms
        count = count + 1

        cooccurlemms = []
        lemtuples = filter(t -> t.lexeme == lemm, tuples1)
        lemmalabel = lemm * ":" * lemtuples[1].label

        #if mod(count, messageinterval) == 0
        @info("$(lemmalabel): $(count) / $(length(unique(lemmalist))). $(length(lemtuples)) passages in source 1")
        #end

        passagecount = 0
        for t1 in lemtuples
            passagecount = passagecount + 1
            @info("$(count) / $(length(unique(lemmalist))) -> $(lemmalabel): $(t1.ref) $(passagecount) / $(length(lemtuples))")
            matches = filter(t2 -> t2.ref == t1.ref, tuples2)
            for v in matches
                push!(cooccurlemms, string(v.lexeme,":", v.label))
            end
        end 
        counted = sort(OrderedDict(countmap(cooccurlemms)), rev=true, byvalue=true)
        
        masterdict[lemmalabel] = counted
      
    end

    masterdict
end


function tabulate(dictofdicts)
    output = []
    for k in keys(dictofdicts)
        subdict = dictofdicts[k]
        for k2 in keys(subdict)
            push!(output, string(k,"|", k2, "|", subdict[k2]))
        end
    end
    output
end

h2sgen = cooccurs(oshbconc, septgenesis) |> tabulate
