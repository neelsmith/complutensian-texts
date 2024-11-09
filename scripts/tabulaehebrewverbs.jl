using BiblicalHebrew, Orthography
using BrownDriverBriggs
using CitableBase, CitableText, CitableCorpus

srcurl = "https://raw.githubusercontent.com/neelsmith/compnov/main/corpus/compnov.cex"
corpus = fromcex(srcurl, CitableTextCorpus, UrlReader)
hebrew = filter(corpus.passages) do psg
	versionid(psg.urn) == "masoretic"
end |> CitableTextCorpus


function strongverb(s; poscode = "v")
    plusentries = bdbplus(s)
    posarticles = filter(plusentries) do plusentry
        strongs = strong(plusentry)
        !isempty(filter(st -> pos(st) == poscode, strongs))
    end


	map(posarticles ) do v
		(lemma = headword(bdb(v)), id = id(bdb(v)))
	end
end

function findverbs(c::CitableTextCorpus; start = 1, limit = length(c.passages), ortho = HebrewOrthography())
	
	for (i,psg) in enumerate(c.passages[start:limit])
		@info("Process $(i) / $(limit - start) + 1 ($(workid(psg.urn)), $(passagecomponent(psg.urn)))")
		reslts = []
		psglex = filter(tokenize(psg , ortho)) do t
			tokencategory(t) isa LexicalToken
		end

		for lextkn in psglex
			for strongv in strongverb(lextkn.passage.text)
				oneresult = (urn = lextkn.passage.urn, form = lextkn.passage.text, headword = strongv.lemma, id = strongv.id)
				push!(reslts, oneresult)
			end
        end
		delimited = map(reslts) do v
			join([v.urn, v.form, v.headword, v.id], "|")
		end
		outfile = string(workid(psg.urn), "_",  passagecomponent(psg.urn), ".cex")
		open(outfile, "w") do io
			write(io, join(delimited, "\n") * "\n")
		end
	end
	@info("Completed run from $(start)-$(limit)")
end

# Timing out. :-(
# try in batches of 500-1000
@time findverbs(hebrew; start = 23001) #, limit = 23000)


vlist = findverbs(CitableTextCorpus(hebrew.passages[1:10]))

vlist