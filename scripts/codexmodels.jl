using CitableText
repo = pwd()


# Read data for incipits some other time...
#=
f = joinpath(repo, "data", "incipits.cex")

datalines = filter(ln -> !isempty(ln), readlines(f)[2:end])
data = map(datalines) do ln
	(passage, page, image) = split(ln, "|")
	(passage = passage, page = page, image = image)
end



incipits = map(data) do trip
    #@info(trip)
	ref = split(trip.page, ":")[5]
	(vol, quire, page) = split(ref, "_")
	(passage = CtsUrn(trip.passage), quire = quire, page = page)
end
=#


"""Compose declaration of CEX model for a Codex."""
function preface(collurnstring, title)
	collbase = replace(collurnstring, r":$" => "")

"""
#!datamodels
Collection|Model|Label|Description
$(collbase):|urn:cite2:hmt:datamodels.v1:codexmodel|HMT project model of a codex with recto and verso sides to each folio.

#!citecollections
URN|Description|Labelling property|Ordering property|License
$(collbase):|$(title)|$(collbase).label:|$(collbase).sequence:|CC-attribution-share-alike

#!citeproperties
Property|Label|Type|Authority list
$(collbase).sequence:|Page sequence|Number|
$(collbase).image:|Image of page|Cite2Urn|
$(collbase).page:|URN|Cite2Urn|
$(collbase).rv:|Recto or Verso|String|recto,verso
$(collbase).label:|Label|String|
"""
end



"""Compose complete CEX document for a codex."""
function codexmodel(pairs, seq, title)
	imgbaseurn = "urn:cite2:citebne:complutensian.v1:"
	pagebaseurn = "urn:cite2:complut:pages.bne:"

	codexmodel = ["#!citedata",
		"sequence|image|urn|rv|label",
	]
	for pr in pairs
		seq = seq + 1
		rv = endswith(pr.page, "v") ? "verso" : "recto"
		#@info(pr.page)
		(volume, quire, pgref)  = split(pr.page, "_")
		lbl = string("Complutensian Bible, National Library of Spain, ", volume, ", quire ", quire, ", page ", pgref, ".")
		pieces = [seq, imgbaseurn * pr.image, pagebaseurn * pr.page, rv, lbl]
		push!(codexmodel, join(pieces,"|"))
	end
	preface(pagebaseurn, title) * "\n\n" * join(codexmodel, "\n")
end

"""Generate page IDs for a specified number of bifolio sheets with a given quire ID."""
function bifoliopairs(id, num)
	ids = []
	for folio in 1:num
		for pg in ['r', 'v']
			push!(ids, string(id, "_", folio, pg))
		end
	end
	ids
end

"""Generate page IDs for a single bifolio sheeet with a given quire ID."""
function singleton(id)
	ids = []
	for folio in 1:2
		for pg in ['r', 'v']
			push!(ids, string(id, "_", folio, pg))
		end
	end
	ids
end

"""Generate page IDs for a binion with a given quire ID."""
function binion(id)
	bifoliopairs(id, 4)
end

"""Generate page IDs for a ternion with a given quire ID."""
function ternion(id)
	bifoliopairs(id, 6)
end

"""Generate page IDs for a ternion with a given quire ID."""
function quaternion(id)
	bifoliopairs(id, 8)
end

"""For a list of quires, generate list of all pages from a given starting page to a given ending.  If quires are note ternions, also supply a function to generte page ids for a quire.
"""
function pagespan(quires, startpage, endpage; pagefunc = ternion)
	spans  = []
	for q in quires
		#@info("Span $(q)")
		for pg in pagefunc(q)
			push!(spans, pg)
		end
	end
	startidx = findfirst(s -> s == startpage, spans)
	endidx = findfirst(s -> s == endpage, spans)
	if isnothing(startidx) || isnothing(endidx)

		@warn("Bad references: failed to get $(startpage)/$(endpage) ")
		@warn("source was $(quires)")
		[]
	else
		spans[startidx:endidx]
	end
end


"""Format quire + page as a reference string"""
function ref(tuple)
	string(tuple.quire, "_", tuple.page)
end









##################### VOLUME 1 ###########################
"""Generate list of all pages in Complutensian volume 1."""
function volume1pages()
	v1singlealphaquires = filter(map(c -> string(c), collect('a':'z'))) do ch
		ch != "i" && ch != "u"
	end
	v1doublealphaquires = filter(map(c -> repeat(c, 2), collect('a':'z'))) do s
		s != "ii" && s != "uu"
	end
	v1alphas = vcat(v1singlealphaquires, v1doublealphaquires)
	v1alphapages = ternion.(v1alphas) |> Iterators.flatten |> collect
	
	# There are two non-alphabetic quire signs follwing these: one ternion and one quaternion.
	et = ternion("et")
	con = quaternion("con")
	map(vcat(v1alphapages, et, con)) do pg
		"vol1_" * pg
	end
end


function volume1images()
	pageids  = []
	centuries = [
		"v1p", "v1a_p", "v1b_p", "v1c_p", "v1d_p", "v1e_p"
	]
	for c in centuries
		for i in 1:100
			push!(pageids, string(c,i))
		end
	end
	pageids
end


function volume1pairs()
	pairs = []
	v1images = volume1images()
	v1pages = volume1pages()
	pgidx = 0
	for i in 19:600
		pgidx = pgidx + 1
		img = v1images[i]
		pg = v1pages[pgidx]
		push!(pairs, (volume = 1, page = pg, image = img))
	end
	pairs
end


v1model = codexmodel(volume1pairs(), 4, "Complutensian Bible (BNE copy): volume 1 ")

v1modelfile = joinpath(repo, "codex", "bne_v1.cex")
open(v1modelfile,"w") do io
	write(io, v1model)
end



################### VOLUME 2 ##########################

"""Generate list of all pages in Complutensian volume 2."""
function volume2pages()

	a1 = vcat(ternion("a"), ["prolog_1r", "prolog_1v"])

    v2singlealphaquires = filter(map(c -> string(c), collect('b':'z'))) do ch
        ch != "i" && ch != "u"
    end

    v2doublealphaquires = filter(map(c -> repeat(c, 2), collect('a':'t'))) do s
	    s != "ii"
    end

    v2ternions = ternion.(vcat(v2singlealphaquires, v2doublealphaquires))
    trailer = quaternion("vv")
	pageids = vcat([a1], v2ternions, [trailer]) |> Iterators.flatten |> collect
    map(pg -> "vol2_" * pg, pageids)
end

function volume2images()
	pageids  = []
	a = for i in 1:98
		push!(pageids, string("v2a_p",i))
	end
	 
	centuries = [
		"v2b_p", "v2c_p", "v2d_p", "v2e_p"
	]
	for c in centuries
		for i in 1:100
			push!(pageids, string(c,i))
		end
	end
	pageids
end


function volume2pairs()
	pairs = []
	#image p5 is page a 1r
	v2pages = volume2pages()
	v2images = volume2images()

	pgidx = 0
	for i in 5:length(v2images)
		pgidx = pgidx + 1
		img = v2images[i]
		pg = v2pages[pgidx]
		push!(pairs, (volume = 2, page = pg, image = img))
	end
	pairs
end


v2model = codexmodel(volume2pairs(), 4, "Complutensian Bible (BNE copy): volume 2")
v2modelfile = joinpath(repo, "codex", "bne_v2.cex")
open(v2modelfile,"w") do io
	write(io, v2model)
end




##################### VOLUME 5 ###########################
#=

- √ quarternion: title page folowed by introductory material; only second recto is numbered `a ii`; total of 4 bifolios, same content as Madrid
- √ the Gospels in continuously  numbered quires `A` - `O` (probably all ternions)
- √ the travels of Paul in a single ternion `α` with all rectos labelled
- √ the continuation of the NT from 'R` - `MM` presumably all ternions
- √ explanations of names in a single gather of 10 bifolios, rectos `a` - `a vi` identified as normal
- intro to Greek with vocabulary, in quires `a` - `g`. The final quire `g` has only three folios, all three rectos explicitly identified.
=#
function volume5images()
	pageids  = []
	for i in 1:96
		push!(pageids, string("v5a_p",i))
	end
	 
	centuries = [
		"v5b_p", "v5c_p", "v5d_p", "v5e_p"
	]
	for c in centuries
		for i in 1:100
			push!(pageids, string(c,i))
		end
	end
	for i in 1:46
		push!(pageids, string("v5f_p",i))
	end
	pageids
end

function volume5pages()

	preface = vcat(binion("a-preface"))

    gospels = filter(map(c -> string(c), collect('A':'Q'))) do ch
        ch != "I" 
    end
	paul = ternion("α")
	ntsingles =  filter(map(c -> string(c), collect('R':'Z'))) do ch
        ch != "I"  && ch != "U" && ch != "W"
    end
	ntdoubles =  filter(map(c -> repeat(c, 2), collect('A':'L'))) do c
		c != "II"
	end
	nttrail = quaternion("MM")

	# gather of 10 bifolios!!!
	# giant = ....
	names = bifoliopairs("a-names", 10)

	# vocabulary
	vocabternions = ternion.(map(c -> string(c), collect('a':'f')))
	vocabtrail = vcat(singleton("g"), ["g_3r", "g_3v"])
	vocab = vcat(vocabternions, [vocabtrail])

	pageids = vcat([preface],ternion.(gospels), [paul], ternion.(ntsingles), ternion.(ntdoubles), [nttrail], [names], vocab ) |> Iterators.flatten |> collect


    map(pg -> "vol5_" * pg, pageids)
end

function volume5pairs()
	pairs = []
	v5images = volume5images()
	v5pages = volume5pages()
	pgidx = 0
	for i in 1:length(v5pages)
		pgidx = pgidx + 1
		img = v5images[i]
		pg = v5pages[pgidx]
		push!(pairs, (volume = 5, page = pg, image = img))
	end
	pairs
end


v5pgs = volume5pages()

v5model = codexmodel(volume5pairs(), 0, "Complutensian Bible (BNE copy): volume 5")
v5modelfile = joinpath(repo, "codex", "bne_v5.cex")
open(v5modelfile,"w") do io
	write(io, v5model)
end

##################### VOLUME 6 ###########################

#=
In Huntington:

√ 1. title page with address to reader on verso
√ 2. hebrew vocab in quires `A` - `FF`, final quire `FF` containing 4 pages with rectos numbered (binion). Colophon to this quire dates it to 17 March, 1515.
√ 3. introduction to Hebrew grammar in quires `A` - `C`, final quire `C` with three pages of content, all rectos identified. A single blank page for final verso showing this is done by quire. 
√ 4. Index of Latin terms in a single quaternion with rectos labelled `A` or `a` 1 - 5.
√ 5. Interpretations of Latin names in quires `A` - `D` (all ternions)
√ 6. Same quire sequence continues with alternate forms of names, a sinqule binion with first recto labeled `E` .
 
=#

"""Generate list of all pages in Complutensian volume 6."""
function volume6pages()
	# section: preface
	preface = ["title_1r", "title_1v"]

	# section: Hebrew lexicon
    v6ucquires = filter(map(c -> string(c), collect('A':'Z'))) do ch
        ch != "I" && ch != "U" && ch != "W"
    end
    v6doublealphaquires = map(c -> repeat(c, 2), collect('A':'E'))
	ff = [binion("FF")]
	ternions = ternion.(vcat(v6ucquires, v6doublealphaquires))
	hebrewlexicon = vcat(ternions, ff) |> Iterators.flatten |> collect
	
	# section: Latin index
	idx = quaternion("A-index")

	#hebrewgrammar = [ternion("A"), ternion("B"), singleton("C")] |> Iterators.flatten |> collect

	# section: interpretation of names
	# Messed up in BNE copy!
	names_a1 = ternion("A-names")
	names_continued = ternion.(["B-names", "C-names", "D-names"]) |> Iterators.flatten |> collect

	# section: alternate forms of names
	altforms = singleton("E-names")

	# section: hebrew grammar
	grammarternions = vcat([ternion("A-grammar"), ternion("B-grammar"),singleton("C-grammar")])  |> Iterators.flatten |> collect
	grammar = vcat(grammarternions, ["C-grammar_3r", "C-grammar_3v"])

	bnesequence = vcat(preface, hebrewlexicon, names_a1, idx, names_continued, altforms, grammar)

	
    
    map(pg -> "vol6_" * pg, bnesequence)
end

function volume6images()
	pageids  = []
	for i in 1:96
		push!(pageids,string("v6p",i))
	end
	centuries = [
	  "v6b_p", "v6c_p", "v6d_p"
	]
	for c in centuries
		for i in 1:100
			push!(pageids, string(c,i))
		end
	end
	for i in 1:48
		push!(pageids, string("v6e_p", i))
	end
	pageids
end


function volume6pairs()
	pairs = []
	#image p3 is page a 1r
	v6pages = volume6pages()
	v6images = volume6images()

	pgidx = 0
	#for i in 5:length(v6images)
	for i in 1:length(v6pages)
		pgidx = pgidx + 1
		img = v6images[i]
		pg = v6pages[pgidx]
		@info("pair $(pg) / $(img)")
		push!(pairs, (volume = 6, page = pg, image = img))
	end
	pairs
end

v6pairs = volume6pairs()
v6pgs = volume6pages()


v6model = codexmodel(volume6pairs(), 4, "Complutensian Bible (BNE copy): volume 6")
v6modelfile = joinpath(repo, "codex", "bne_v6.cex")
open(v6modelfile,"w") do io
	write(io, v6model)
end


v6prs  = volume6pairs()