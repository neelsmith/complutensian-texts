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

"""Format quire + page as a reference string"""
function ref(tuple)
	string(tuple.quire, "_", tuple.page)
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






#########################################################################
#
####### COMPOSE CODEX MODELS FOR 6 VOLUMES OF COMPLUTENSIAN IN BNE ######
#
##################### VOLUME 1 ##########################################
"""Generate list of all pages in Complutensian volume 1."""
function volume1pages()
	pref = vcat(ternion("+"), ["+_7r", "+_7v"])

	v1singlealphaquires = ternion.(filter(map(c -> string(c), collect('a':'v'))) do ch
		ch != "i" && ch != "u" && ch != "w"
	end)

	badx = [
		"x_2r", "x_2v",
		"x_2bisr", "x_2bisv",
		"x_3r", "x_3v",
		"x_4r", "x_4v",
		"x_5r", "x_5v",
		"x_6r", "x_6v"
	]
	yz = ternion.(["y", "z"])

	v1doublealphaquires1 = ternion.(filter(map(c -> repeat(c, 2), collect('a':'d'))) do s
		s != "ii" && s != "uu"
	end)
	deficient = ["ee_1r", "ee_1v",  "ee_3r", "ee_3v", "ee_4r", "ee_4v", "ee_6r", "ee_6v", "ee_7r", "ee_7v"]
	v1doublealphaquires2 = ternion.(filter(map(c -> repeat(c, 2), collect('f':'z'))) do s
		s != "ii" && s != "uu" && s != "ww"
	end)
	v1alphapages = vcat(v1singlealphaquires,  [badx], yz, v1doublealphaquires1, [deficient], v1doublealphaquires2 ) |> Iterators.flatten |> collect

	# There are two non-alphabetic quire signs follwing these: one ternion and one quaternion.
	et = ternion("et")
	con = quaternion("con")
	map(vcat(pref, v1alphapages, et, con)) do pg
		"vol1_" * pg
	end
end

"""Generate list of all images in Complutensian volume 1."""
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

"""Pair up images and pages for Complutensian volume 1."""
function volume1pairs()
	pairs = []
	v1images = volume1images()
	v1pages = volume1pages()
	pgidx = 0
	for i in 5:(min(length(v1images), length(v1pages)) + 4)
		
		pgidx = pgidx + 1
		#@info("Indices $(i), $(pgidx)")
		img = v1images[i]
		pg = v1pages[pgidx]
		#@info("pair $(pg) / $(img)")
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
#=

1. title page followed by 3 pages of prefatory material (binion?)
2. text of Joshua begins with `a` - `vv` (end of *Paralipomenon*) with the final quire `vv` having only 4 pages (a binion) with the first three numbered.
3. corrigenda in four pages, the first recto labelled `a`
=#
"""Generate list of all pages in Complutensian volume 2."""
function volume2pages()
	pref = ["title_1r", "title_1v"]
	a1 = vcat(ternion("a"), ["prolog_1r", "prolog_1v"])

    v2singlealphaquires = filter(map(c -> string(c), collect('b':'z'))) do ch
        ch != "i" && ch != "u" && ch != "w"
    end

    v2doublealphaquires = filter(map(c -> repeat(c, 2), collect('a':'q'))) do s
	    s != "ii"
    end
	rr = ["rr_2r", "rr_2v",
	"rr_2bisr", "rr_2bisv",
	"rr_3r", "rr_3v",
	"rr_4r", "rr_4v",
	"rr_5r", "rr_5v",
	"rr_6r", "rr_6v",
	]
	st = ternion.(["ss", "tt"])

    v2ternions = ternion.(vcat(v2singlealphaquires, v2doublealphaquires))
    trailer = binion("vv")
	pageids = vcat([pref], [a1], v2ternions, [rr], st, [trailer]) |> Iterators.flatten |> collect
    map(pg -> "vol2_" * pg, pageids)
end

"""Generate list of all pages in Complutensian volume 2."""
function volume2images()
	pageids  = []
	a = for i in 1:98
		push!(pageids, string("v2a_p",i))
	end
	 
	centuries = [
		"v2b_p", "v2c_p", "v2d_p", "v2e_p", "v2f_p"
	]
	for c in centuries
		for i in 1:100
			push!(pageids, string(c,i))
		end
	end
	for i in 1:20
		push!(pageids, "v2f_$(i)")
	end
	pageids
end

"""Pair up images and pages for Complutensian volume 2."""
function volume2pairs()
	pairs = []
	#image p5 is page a 1r
	v2pages = volume2pages()
	v2images = volume2images()

	pgidx = 0
	for i in 3:(min(length(v2images), length(v2pages)) + 2)
		pgidx = pgidx + 1
		img = v2images[i]
		pg = v2pages[pgidx]
		#@info("pair $(pg) / $(img)")
		push!(pairs, (volume = 2, page = pg, image = img))
	end
	pairs
end


v2model = codexmodel(volume2pairs(), 4, "Complutensian Bible (BNE copy): volume 2")
v2modelfile = joinpath(repo, "codex", "bne_v2.cex")
open(v2modelfile,"w") do io
	write(io, v2model)
end



##################### VOLUME 3 ###########################
#=
- title page has prefatory material on verso, then two pages of prefatory with recto identified as `aaa ii`. Text of First Esdra continues on `aaa iii`, and runs through end of Nehemiah on `eee` 4. (`eee` is a binion.)
- *Tobias* follows with quire `Aaa`- `Iii`. *Job* ends on `Iii` 4 recto; significantly, Jerome's preface to the Psalms appears on `Iii` 4 verso.  It *must* be followed by the text of the Psalms!
- *Psalms* then begins with a reset to `a`- `p`, ending with *Songs* on `p` 8 verso (`p` is a quaternion).
- *Wisdom* resets to `A`, runs through `F`, ending *Ecclesiastes* on `F` 4 recto.  `F` 4 verso is a blank page. (`F` is a binion.)
- corrigenda. 2 pages followed by a printed blank with red frames (so a binion) with intial recto identified as `a`.
=#


"""Generate list of all pages in Complutensian volume 3."""
function volume3pages()
	v3triples1 = ternion.(map(c -> repeat(c, 3), collect('a':'d'))) |> Iterators.flatten |> collect
    eee = binion("eee")
	pageids = vcat(v3triples1, eee) |> Iterators.flatten |> collect
	map(pg -> "vol3_" * pg, pageids)
end

"""Generate list of all pages in Complutensian volume 3."""
function volume3images()
	imgids = []
	for i in 21:100
		push!(imgids, "v3a_p$(i)")
	end
	centuries = [
	 "v3b_p", "v3c_p",  "v3d_p"
	]
	for c in centuries
		for i in 1:100
			push!(imgids, string(c,i))
		end
	end
	for i in 1:23
		push!(imgids, "v3e_p$(i)")
	end
	imgids
end



"""Pair up images and pages for Complutensian volume 3."""
function volume3pairs()
	pairs = []
	
	v3pages = volume3pages()
	v3images = volume3images()

	pgidx = 0
	for i in 1:min(length(v3images), length(v3pages))
		pgidx = pgidx + 1
		img = v3images[i]
		pg = v3pages[pgidx]
		@info("pair $(pg) / $(img)")
		push!(pairs, (volume = 3, page = pg, image = img))
	end
	pairs
end


v3model = codexmodel(volume3pairs(), 0, "Complutensian Bible (BNE copy): volume 3")
v3modelfile = joinpath(repo, "codex", "bne_v3.cex")
open(v3modelfile,"w") do io
	write(io, v3model)
end

volume3pairs()

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

"""Generate list of all images in Complutensian volume 6."""
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

"""Pair up images and pages for Complutensian volume 6."""
function volume6pairs()
	pairs = []
	#image p3 is page a 1r
	v6pages = volume6pages()
	v6images = volume6images()

	pgidx = 0
	
	
	for i in 1:min(length(v6pages), length(v6images))
		pgidx = pgidx + 1
		#@info("Indices $(i), $(pgidx)")
		img = v6images[i]
		pg = v6pages[pgidx]
		#@info("pair $(pg) / $(img)")
		push!(pairs, (volume = 6, page = pg, image = img))
	end
	pairs
end

v6model = codexmodel(volume6pairs(), 4, "Complutensian Bible (BNE copy): volume 6")
v6modelfile = joinpath(repo, "codex", "bne_v6.cex")
open(v6modelfile,"w") do io
	write(io, v6model)
end


v2prs  = volume2pairs()