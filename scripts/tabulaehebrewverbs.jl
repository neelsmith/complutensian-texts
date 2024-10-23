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


function findverbs(c::CitableTextCorpus; limit = length(c.passages), ortho = HebrewOrthography())
	reslts = []
	for (i,psg) in enumerate(c.passages[1:limit])
		@info("Process $(i) / $(limit)")
		psglex = filter(tokenize(psg , ortho)) do t
			tokencategory(t) isa LexicalToken
		end

		for lextkn in psglex
			for strongv in strongverb(lextkn.passage.text)
				oneresult = (urn = lextkn.passage.urn, form = lextkn.passage.text, headword = strongv.lemma, id = strongv.id)
				push!(reslts, oneresult)
			end
        end
	end
	reslts
end

@time allverbs = findverbs(hebrew)


delimited = map(allverbs) do v
    join([v.urn, v.form, v.headword, v.id], "|")
end

open("hebrewverbs.cex", "w") do io
    write(io, "urn|form|lemma|id\n" * join(delimited, "\n"))
end