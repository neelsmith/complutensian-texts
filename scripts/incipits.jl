
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
