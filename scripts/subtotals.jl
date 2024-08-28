countsfile = joinpath(pwd(), "cex-editions", "lxxglosses-freqs.tsv")
countpairs = map(readlines(countsfile)) do ln
    cols = split(ln, "\t")
    (token = cols[1], count = parse(Int, cols[2]))
end


verbsfile = joinpath(pwd(), "cex-editions", "lxxglosses-verbs.txt")
verbs = readlines(verbsfile)

function subtotal(token; countpairs = countpairs, verbs = verbs)
    countslist = []

    idx = findfirst(ln -> ln == token, verbs)

    for i in 1:idx
        #countidx = findfirst(pr -> pr.token == verbs[i], countpairs)
        verbform = verbs[i]
        countidx = findfirst(pr -> pr.token == verbform, countpairs)
        @info("Try for $(verbform): index $(countidx)")
        push!(countslist, countpairs[countidx].count)
    end
    countslist |> sum
end

subtotal("clamans")
#=
token = "abiens"
idx = findfirst(ln -> ln == token, verbs)
countslist = []
for i in 1:idx
    verbform = verbs[i]
    
    
    countidx = findfirst(pr -> pr.token == verbform, countpairs)
    @info("Try for $(verbform): index $(countidx)")
    push!(countslist, countpairs[countidx].count)
end

sum(countslist)
=#