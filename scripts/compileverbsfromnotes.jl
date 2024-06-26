f = joinpath(pwd(), "notes", "verbs-gen.17ff.cex")


rawlines = readlines(f)

lines = filter(l -> ! isempty(l), rawlines)
verblists = map(lines) do ln
    split(ln, "|")[2]
end

verbs = []
for vlist in verblists
    items = split(vlist,",")
    for i in items
        push!(verbs, lowercase(strip(i)))
    end
end

tbds = verbs |> unique |> sort


open("verbstbd.txt", "w") do io
    write(io, join(tbds, "\n"))
end