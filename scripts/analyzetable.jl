using TypedTables
using CSV 
using Downloads
using OrderedCollections
using StatsBase

# Get data
url = "http://shot.holycross.edu/complutensian/verblexemes-current.csv"
function readurl(u)
	tmp = Downloads.download(u)
	s = read(tmp, String)
	rm(tmp)
	s
end
data = CSV.File(IOBuffer(readurl(url))) |> Table



## Analysis
psglist = map(r -> r.sequence, data) |> unique
verblist = map(r -> r.lexeme, data) |> unique


"""Get set of unique lexemes in passage seq."""
function lexemesforpsg(seq, tbl)
	map(filter(r -> r.sequence == seq, tbl)) do r
		r.lexeme
	end |> unique
end

"""Compile dict of counts for verbs keyed by passage."""
function occurrencesbypsg(tbl::Table, psgs = psglist)
	counts = Dict()
	for psg in psgs
		psgverbs= map(filter(r -> psg == r.sequence, tbl)) do r
            r.lexeme
        end
        counts[psg] = countmap(psgverbs)
		
	end
	sort(OrderedDict(counts))
end

"""Identify by sequence number passages where a given verb occurs."""
function verboccurrences(vrb, tbl::Table)
	map(filter(r -> r.lexeme == vrb, tbl)) do r
		r.sequence
	end |> unique
end


dict = countalignments(psglist[1:4], data)



function occurrencesbyverb(tbl::Table, verbs = verblist)
	counts = Dict()
	for verb in verbs
		subcounts = Dict()
		psgs = verboccurrences(verb, tbl)
		for psg in psgs
			count = filter(r -> r.sequence == psg && r.lexeme == verb, tbl) |> length
            subcounts[psg] = count
		end
		counts[verb] = subcounts
	end
	counts
end


occurrencesbyverb(data, verblist[2:2])