### A Pluto.jl notebook ###
# v0.19.47

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ ba8551dd-cab7-41a1-a2da-0a0bc40d5a5d
begin
	using TypedTables
	using CSV 
	using OrderedCollections
	using StatsBase
	using Downloads

	using PlutoUI
	md"""*Unhide this cell to see the Julia environment*."""
end

# ╔═╡ 63c8604f-f7a5-45c5-97ef-166c0d2e991d
TableOfContents()

# ╔═╡ dc38efac-3082-11ef-3f55-01dab0c1e1dc
md"""# Verb vocabulary in Latin texts of the Complutensian Bible"""

# ╔═╡ 52556a06-16b3-48b2-851b-fbec08ed0216
md"""*See verbs with no variation*: $(@bind showperfect CheckBox())"""

# ╔═╡ 9034bac7-b3ab-49d0-8826-13feef69d288
if showperfect
	md"""## Verbs with consistent correspondences"""
end

# ╔═╡ e95af135-0956-4192-8db1-95fbf60f1726
md"""## Most likely alignments"""

# ╔═╡ 2204a739-4aa3-4c4e-804f-9ab6def9f46c
md"""*Max number rows to show:* $(@bind maxn Slider(1:20, default = 3, show_value = true))"""

# ╔═╡ 6c96e798-fb4d-413d-945f-7e4fdc06971b
#labelverb("ls.n19570")

# ╔═╡ dec7092c-a502-4744-8fe3-47b0fa9a5d7a
html"""
<br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/>
<hr/>
"""

# ╔═╡ 935d0425-fda9-4c63-ae62-fedc1062dc80
md"""> # Mechanics"""

# ╔═╡ 79f0006b-d4e9-4408-aaa9-19e97794721d
md"""> ## Labels"""

# ╔═╡ 76978cd6-021c-4d22-9c4c-20c36c241146
lblurl = "http://shot.holycross.edu/complutensian/labels.cex"

# ╔═╡ 949f45b5-f5a4-40df-905d-5776aa745194
function loadlabels(lblurl)
	tmplbls = Downloads.download(lblurl)
	lns = readlines(tmplbls)
	rm(tmplbls)
	dict = Dict()
	for ln in lns
		parts = split(ln, "|")
		dict[parts[1]] = string(parts[1], " (", parts[2], ")")
	end
	dict
end

# ╔═╡ 906ac4ef-f20f-4f3e-97a9-b786d6e5d362
labelsdict = loadlabels(lblurl)

# ╔═╡ d02b374f-eae6-4b8c-85dd-f94a862e8c03
function labelverb(v, dict = labelsdict)
	if haskey(dict, v)
		dict[v]
	else
		string(v, " (?)")
	end
end

# ╔═╡ f21c6986-665b-455f-bd56-420368e96985
md"""> ## Analyses"""

# ╔═╡ 01fb72c0-34e6-482d-ba76-e2cbcb54e0c1
md"""> ### Alignment computations"""

# ╔═╡ 769175d2-9b80-41e8-b33a-6a9bd4fb5a21
"""Find highest scoring verb aligned with v."""
function topmatch(v, scores)
	matchingkeys = scores[v] |> keys |> collect
	matchingkeys[1]
end

# ╔═╡ 10cf8ccc-575f-4047-b0e5-6022cd0b4790
"""Find highest scoring verb aligned with v."""
function topmatches(v, n, scores)
	matchingkeys = scores[v] |> keys |> collect
	length(matchingkeys) < n ? matchingkeys : matchingkeys[1:n]
end

# ╔═╡ f70040a9-c775-4261-ad4b-858a423160dc
function topscores(vrb, n, scores)
	verblist = topmatches(vrb,n,scores)
	map(verblist) do v
		scores[v][vrb]
	end
end

# ╔═╡ 95a77774-be14-4c19-bfd8-67b51cd6317b
"""Find count of highest scoring verb aligned v."""
function topscore(v, scores)
	verbid = topmatch(v, scores)
	scores[v][verbid]
end

# ╔═╡ 69787159-9b22-49e7-a112-f48455978f27
md"""> ### Basic analysis structures"""

# ╔═╡ 724d24ea-434d-4df6-8432-b8a96bf8f981
md"""> ### Scoring a verb"""

# ╔═╡ 0fa58f27-19ee-49b6-9ea7-e7670522ef75
md"""> ### Organizing functions"""

# ╔═╡ 0889e4be-6ef2-494e-a89b-2cfe70de0aba
"""Identify by sequence number passages where a given verb occurs."""
function verboccurrences(vrb, tbl::Table)
	map(filter(r -> r.lexeme == vrb, tbl)) do r
		r.sequence
	end |> unique
end

# ╔═╡ 40d731db-1a85-41c0-be16-a6d37d505fef
"""Get set of unique lexemes in passage seq."""
function lexemesforpsg(seq::Int, tbl::Table)
	map(filter(r -> r.sequence == seq, tbl)) do r
		r.lexeme
	end |> unique
end

# ╔═╡ efb0cd24-f3d5-4cd4-aa09-09b326cbbc90
"""Get set of documents where verb appears in passage seq."""
function documentsforverb(vrb, tbl::Table)
	map(filter(r -> r.lexeme == vrb, tbl)) do r
		r.document
	end |> unique
end

# ╔═╡ c275a0ec-505c-4707-98cb-65b3748ade01
"""Count occurrences of other verbs in documents where a verb found in one or two documents does not appear."""
function scorecooccurs(v, tbl::Table)
	docids = ["septuagint", "targum", "vulgate"]
	allalignments = []
	psgs = verboccurrences(v, tbl)
	
	for psg in psgs
		records = filter(r -> r.sequence == psg, tbl)
		appearsin = documentsforverb(v, records)
		missingdocs = filter(r -> (r.document in appearsin) == false, records)
		otherlexx = map(r -> r.lexeme, missingdocs)
		for l in otherlexx
			push!(allalignments, l)
		end
	end
	
	dict = allalignments |> countmap |> OrderedDict
	sort(dict, byvalue=true, rev=true)
	
end

# ╔═╡ 57b55606-9de0-4b70-b7f9-f1a284e85122
md"""> ## Data"""

# ╔═╡ dc209e93-b8d3-499e-b098-a1a00506bdea
sum = "ls.n46529"

# ╔═╡ 8f8bc7bf-a429-4e4f-aef6-47989cfa8d14
url = "http://shot.holycross.edu/complutensian/verblexemes-current.csv"

# ╔═╡ ec8d0ff7-fcfa-4d50-a42f-76f21dcd22ef
function readurl(u)
	tmp = Downloads.download(u)
	s = read(tmp, String)
	rm(tmp)
	s
end

# ╔═╡ 99296753-8af1-4d7a-be93-39856b80977a
dataraw = CSV.File(IOBuffer(readurl(url))) |> Table

# ╔═╡ 5e2af74c-5e29-491c-b1e5-89c68ed60dca
data = filter(r -> r.lexeme != sum, dataraw)

# ╔═╡ 95a015ef-431c-4907-9047-d120deae6c05
psglist = map(r -> r.sequence, data) |> unique

# ╔═╡ 96013e87-36c4-4125-8be0-92731e8a4a85
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

# ╔═╡ 9567d52f-9935-445c-ab7c-65aa45730cb0
verblistraw = map(r -> r.lexeme, data) |> unique

# ╔═╡ 209400c7-6d75-4ef7-aab8-5a4e250ddf78
 verblist = filter(v -> v != "ls.n46529", verblistraw)

# ╔═╡ f32b2688-2f99-42d2-92f0-d5790a41e337
"""Compile dict of counts for verbs keyed by lexeme."""
function occurrencesbyverb(tbl::Table, verbs = verblist)
	counts = OrderedDict()
	for verb in verbs
		subcounts = OrderedDict()
		psgs = verboccurrences(verb, tbl)
		for psg in psgs
			count = filter(r -> r.sequence == psg && r.lexeme == verb, tbl) |> length
            subcounts[psg] = count
		end
		counts[verb] = subcounts
	end
	counts
end


# ╔═╡ e13a4f41-5bd9-41dc-8b10-ed388c28142a
psgverbdict = occurrencesbypsg(data, psglist)

# ╔═╡ 2acf348c-66e4-4abd-a1a5-6cfe21e3278d
verbpsgdict = occurrencesbyverb(data, verblist)

# ╔═╡ ce3daace-f4f0-40f5-8b1f-fc002f90c9ca
begin
	psgcounts = Dict()
	for k in (keys(verbpsgdict) |> collect)
		psgcounts[k] = length(verbpsgdict[k])
	end
	psgcounts
end

# ╔═╡ 04395ebe-0fe3-489e-9fa2-08ef36766d78
"""Compute numbers of triples, doubles, singeltons and totals for a verb."""
function slashline(vrb,tbl::Table)
	occrncs =  verboccurrences(vrb, tbl)
	psgcounts = verbpsgdict[vrb]
	triples = filter(occrncs) do seq
		psgcounts[seq] == 3
	end
	doubles = filter(occrncs) do seq
		psgcounts[seq] == 2
	end
	singles = filter(occrncs) do seq
		psgcounts[seq] == 1
	end
	[vrb, length(triples), length(doubles), length(singles), length(occrncs)]

end

# ╔═╡ 3d490270-d40d-417d-b842-60c64859383c
slashlines = map(verblist) do v
	slashline(v, data)
end

# ╔═╡ ebb2cf3f-4af5-4dc5-be18-4ea9c25d4ee3
"""Number of passages without perfect threes."""
function missingscores(vrb, slashes)
	slash = filter(v -> v[1] == vrb, slashlines)[1]
	slash[5] - slash[2]
end

# ╔═╡ 40e4d8af-d892-4f7e-a14d-3b34556b3340
slashes = map(v -> slashline(v, data), verblist)

# ╔═╡ a043feef-54a9-4e14-99e0-ac16ca05453e
perfectthrees = filter(v -> v[5] == v[4], slashes)

# ╔═╡ e3414136-2fce-4e69-be32-faec72d87cee
perfectsorted = sort(perfectthrees, by = v -> v[5], rev = true)

# ╔═╡ 5080ca9c-b7f6-4b29-b6d2-c081f322552f
if showperfect
	perfect_listitems = map(perfectsorted) do v
		string("- ", labelverb(v[1]),": ", v[5], " occurrences")
	end
	join(perfect_listitems, "\n") |> Markdown.parse
end

# ╔═╡ 518e21c9-1128-4b52-b5ab-5c35d5daf8a1
scorecooccurs("ls.n13804", data)

# ╔═╡ 849b211e-2fdf-4c2c-9f76-c88151eb9f25
"""Compute cooccurence score for all verbs except sum."""
function scoreall()
	allscores = Dict() 
	for v in verblist
		verbscore = scorecooccurs(v,data)
		allscores[v] = verbscore
	end
	allscores
end
	

# ╔═╡ b27cf89d-0953-416c-958b-4fa9e73b758b
allscores = scoreall()

# ╔═╡ be7c3188-15a8-4aeb-811c-a3fb00a2b25d
"""Build menu for seeing verb scores."""
function menu()
	vlist = allscores |> keys |> collect

	


	
	verbmenu = Pair{String, String}[]
	for v in sort(vlist, by = vrb -> psgcounts[vrb], rev=true)
		pr =  Pair(v,  labelverb(v))
		push!(verbmenu, pr)
	end
	verbmenu
end

# ╔═╡ 40e231cd-93ab-4d6e-9647-3693e768069a
md"""*See verbs co-occurring with*: $(@bind vchoice Select(menu()))"""

# ╔═╡ ffb74786-2de1-4c9e-8d12-b9ac69afd9f3
md"""Number of passages: **$(psgcounts[vchoice])**"""

# ╔═╡ 21d03185-d844-477f-96c8-bcfcbfe32752
md"""Passages without a perfect alignment: **$(missingscores(vchoice, slashlines))**"""

# ╔═╡ f58bff56-8664-4d00-ab64-82e796dfea89
md"""Top match:  **$(labelverb(topmatch(vchoice, allscores)))**"""

# ╔═╡ e6c7e669-1733-43f2-90b5-122b5f055eb6
md"""Top score: **$(topscore(vchoice, allscores))**"""

# ╔═╡ 8ba7b87f-06b8-4e38-9ea3-cf4ae8af0d62
topmatches(vchoice, maxn, allscores)

# ╔═╡ 67a9013c-901f-4835-a2ac-fb115e2ef5d3
topmatches(vchoice, maxn, allscores) .|> labelverb

# ╔═╡ e8c3c389-7732-4196-8bd8-922545c4d231
topscores(vchoice, maxn, allscores)

# ╔═╡ 9bc025ed-ad8d-41d1-adb7-c88429d9e7c2
verbscores = map(v -> scorecooccurs(v,data), verblist)

# ╔═╡ 5a0acb01-0299-4d00-8c90-eed19cf95e69
verbscores |> keys |> collect

# ╔═╡ 621b85af-930b-4907-b889-2417227f6d71
data

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
OrderedCollections = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
TypedTables = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"

[compat]
CSV = "~0.10.14"
OrderedCollections = "~1.6.3"
PlutoUI = "~0.7.59"
StatsBase = "~0.34.3"
TypedTables = "~1.4.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.6"
manifest_format = "2.0"
project_hash = "69b141edf15cdc5adcf1191f74737b7180c26a27"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "6a55b747d1812e699320963ffde36f1ebdda4099"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.0.4"

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

    [deps.Adapt.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "6c834533dc1fabd820c1db03c839bf97e45a3fab"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.14"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "59939d8a997469ee05c4b4944560a820f9ba0d73"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.4"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "b1c55339b7c6c350ee89f2c1604299660525b248"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.15.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "35b66b6744b2d92c778afd3a88d2571875664a2a"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.4.2"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "9f00e42f8d99fdde64d40c8ea5d14269a2e2c1aa"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.21"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "86356004f30f8e737eff143d57d41bd580e437aa"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.1"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a2d09619db4e765091ee5c6ffe8872849de0feea"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.28"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "ab55ee1510ad2af0ff674dbcced5e94921f867a9"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.59"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "90b4f68892337554d31cdcdbe19e48989f26c7e6"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.3"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.SplitApplyCombine]]
deps = ["Dictionaries", "Indexing"]
git-tree-sha1 = "c06d695d51cfb2187e6848e98d6252df9101c588"
uuid = "03a91e81-4c3e-53e1-a0a4-9c0c8f19dd66"
version = "1.2.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
git-tree-sha1 = "a947ea21087caba0a798c5e494d0bb78e3a1a3a0"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.9"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.TypedTables]]
deps = ["Adapt", "Dictionaries", "Indexing", "SplitApplyCombine", "Tables", "Unicode"]
git-tree-sha1 = "84fd7dadde577e01eb4323b7e7b9cb51c62c60d4"
uuid = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"
version = "1.4.6"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─ba8551dd-cab7-41a1-a2da-0a0bc40d5a5d
# ╟─63c8604f-f7a5-45c5-97ef-166c0d2e991d
# ╟─dc38efac-3082-11ef-3f55-01dab0c1e1dc
# ╟─52556a06-16b3-48b2-851b-fbec08ed0216
# ╟─9034bac7-b3ab-49d0-8826-13feef69d288
# ╟─5080ca9c-b7f6-4b29-b6d2-c081f322552f
# ╟─e95af135-0956-4192-8db1-95fbf60f1726
# ╟─40e231cd-93ab-4d6e-9647-3693e768069a
# ╟─ffb74786-2de1-4c9e-8d12-b9ac69afd9f3
# ╟─21d03185-d844-477f-96c8-bcfcbfe32752
# ╟─f58bff56-8664-4d00-ab64-82e796dfea89
# ╟─e6c7e669-1733-43f2-90b5-122b5f055eb6
# ╟─2204a739-4aa3-4c4e-804f-9ab6def9f46c
# ╠═8ba7b87f-06b8-4e38-9ea3-cf4ae8af0d62
# ╠═67a9013c-901f-4835-a2ac-fb115e2ef5d3
# ╠═e8c3c389-7732-4196-8bd8-922545c4d231
# ╠═6c96e798-fb4d-413d-945f-7e4fdc06971b
# ╟─dec7092c-a502-4744-8fe3-47b0fa9a5d7a
# ╟─935d0425-fda9-4c63-ae62-fedc1062dc80
# ╟─be7c3188-15a8-4aeb-811c-a3fb00a2b25d
# ╟─79f0006b-d4e9-4408-aaa9-19e97794721d
# ╟─d02b374f-eae6-4b8c-85dd-f94a862e8c03
# ╟─906ac4ef-f20f-4f3e-97a9-b786d6e5d362
# ╟─76978cd6-021c-4d22-9c4c-20c36c241146
# ╟─949f45b5-f5a4-40df-905d-5776aa745194
# ╟─f21c6986-665b-455f-bd56-420368e96985
# ╟─01fb72c0-34e6-482d-ba76-e2cbcb54e0c1
# ╠═5a0acb01-0299-4d00-8c90-eed19cf95e69
# ╠═769175d2-9b80-41e8-b33a-6a9bd4fb5a21
# ╠═10cf8ccc-575f-4047-b0e5-6022cd0b4790
# ╠═f70040a9-c775-4261-ad4b-858a423160dc
# ╠═95a77774-be14-4c19-bfd8-67b51cd6317b
# ╟─ebb2cf3f-4af5-4dc5-be18-4ea9c25d4ee3
# ╟─69787159-9b22-49e7-a112-f48455978f27
# ╟─95a015ef-431c-4907-9047-d120deae6c05
# ╠═9567d52f-9935-445c-ab7c-65aa45730cb0
# ╠═209400c7-6d75-4ef7-aab8-5a4e250ddf78
# ╟─e13a4f41-5bd9-41dc-8b10-ed388c28142a
# ╠═2acf348c-66e4-4abd-a1a5-6cfe21e3278d
# ╠═ce3daace-f4f0-40f5-8b1f-fc002f90c9ca
# ╟─3d490270-d40d-417d-b842-60c64859383c
# ╟─724d24ea-434d-4df6-8432-b8a96bf8f981
# ╟─40e4d8af-d892-4f7e-a14d-3b34556b3340
# ╟─a043feef-54a9-4e14-99e0-ac16ca05453e
# ╟─e3414136-2fce-4e69-be32-faec72d87cee
# ╟─518e21c9-1128-4b52-b5ab-5c35d5daf8a1
# ╟─849b211e-2fdf-4c2c-9f76-c88151eb9f25
# ╠═b27cf89d-0953-416c-958b-4fa9e73b758b
# ╟─c275a0ec-505c-4707-98cb-65b3748ade01
# ╠═9bc025ed-ad8d-41d1-adb7-c88429d9e7c2
# ╟─0fa58f27-19ee-49b6-9ea7-e7670522ef75
# ╟─f32b2688-2f99-42d2-92f0-d5790a41e337
# ╟─96013e87-36c4-4125-8be0-92731e8a4a85
# ╟─0889e4be-6ef2-494e-a89b-2cfe70de0aba
# ╟─40d731db-1a85-41c0-be16-a6d37d505fef
# ╟─efb0cd24-f3d5-4cd4-aa09-09b326cbbc90
# ╠═04395ebe-0fe3-489e-9fa2-08ef36766d78
# ╟─57b55606-9de0-4b70-b7f9-f1a284e85122
# ╠═dc209e93-b8d3-499e-b098-a1a00506bdea
# ╟─8f8bc7bf-a429-4e4f-aef6-47989cfa8d14
# ╠═99296753-8af1-4d7a-be93-39856b80977a
# ╠═5e2af74c-5e29-491c-b1e5-89c68ed60dca
# ╠═621b85af-930b-4907-b889-2417227f6d71
# ╟─ec8d0ff7-fcfa-4d50-a42f-76f21dcd22ef
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
