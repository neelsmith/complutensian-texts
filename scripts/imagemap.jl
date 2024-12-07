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
	v1alphapages = ternion.(v1alphas) |> Iterators.flatten |> collect
	v1alphas = vcat(v1singlealphaquires, v1doublealphaquires)
	# There are two non-alphabetic quire signs follwing these: one ternion and one quaternion.
	et = ternion("et")
	con = quaternion("con")
	vcat(v1alphapages, et, con)
end

"""Generate list of all pages in Complutensian volume 2."""
function volume2pages()
    v2singlealphaquires = filter(map(c -> string(c), collect('a':'z'))) do ch
        ch != "i" && ch != "u"
    end

    v2doublealphaquires = filter(map(c -> repeat(c, 2), collect('a':'t'))) do s
	    s != "ii"
    end

    v2ternions = ternion.(vcat(v2singlealphaquires, v2doublealphaquires))
    trailer = quaternion("vv")
    vcat(v2ternions, trailer) |> Iterators.flatten |> collect
end



v2pages = volume2pages()

v2pages[98]
## vol 2 page a_1r == image 2a_p5
# through
## vol 2 page j_1v == image 2a_p98


