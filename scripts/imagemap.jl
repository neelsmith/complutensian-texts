using CitableText
repo = pwd()
f = joinpath(repo, "data", "incipits.cex")

datalines = filter(ln -> !isempty(ln), readlines(f)[2:end])
data = map(datalines) do ln
	(passage, page, image) = split(ln, "|")
	(passage = passage, page = page, image = image)
end



incipits = map(data) do trip
    @info(trip)
	ref = split(trip.page, ":")[5]
	(vol, quire, page) = split(ref, "_")
	(passage = CtsUrn(trip.passage), quire = quire, page = page)
end




"""Generate page IDs for a ternion with a given quire ID."""
function binion(id)
	ids = []
	for folio in 1:4
		for pg in ['r', 'v']
			push!(ids, string(id, "_", folio, pg))
		end
	end
	ids
end


"""Generate page IDs for a ternion with a given quire ID."""
function ternion(id)
	ids = []
	for folio in 1:6
		for pg in ['r', 'v']
			push!(ids, string(id, "_", folio, pg))
		end
	end
	ids
end


"""Generate page IDs for a ternion with a given quire ID."""
function quaternion(id)
	ids = []
	for folio in 1:8
		for pg in ['r', 'v']
			push!(ids, string(id, "_", folio, pg))
		end
	end
	ids
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


function codexmodel(pairs, seq)
	imgbaseurn = "urn:cite2:citebne:complutensian.v1:"
	pagebaseurn = "urn:cite2:complut:pages.bne:"

	codexmodel = ["#!citedata",
		"sequence|image|page|rv|label",
	]
	for pr in pairs
		seq = seq + 1
		rv = endswith(pr.page, "v") ? "verso" : "recto"
		@info(pr.page)
		(volume, quire, pgref)  = split(pr.page, "_")
		lbl = string("Complutensian Bible, National Library of Spain, ", volume, ", quire ", quire, ", page ", pgref, ".")
		pieces = [seq, imgbaseurn * pr.image, pagebaseurn * pr.page, rv, lbl]
		push!(codexmodel, join(pieces,"|"))
	end
	join(codexmodel, "\n")
end

v1model = codexmodel(volume1pairs(), 4)

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


v2model = codexmodel(volume2pairs(), 4)
v2modelfile = joinpath(repo, "codex", "bne_v2.cex")
open(v2modelfile,"w") do io
	write(io, v2model)
end
