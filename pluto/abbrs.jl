### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# ╔═╡ 8637f512-3e4c-11ef-1819-4d43d3819374
begin
	using CitableBase, CitableText, CitableCorpus
	using CitableTeiReaders

	using Orthography, LatinOrthography

	using StatsBase, OrderedCollections
	using EzXML

	using PlutoPlotly
	using PlutoUI

	md"""*Unhide this cell to see the Julia environment.*"""
end


# ╔═╡ c042965c-5de9-4675-8852-703c49f6b8d5
TableOfContents()

# ╔═╡ 3e8ef72a-be16-40d4-8a84-9391e3eca5b8
md"""# Analyzing abbreviations"""

# ╔═╡ 07b79a8a-b569-4ced-a495-f0528d3e6024
md"""### Targum glosses"""

# ╔═╡ 98175044-9e89-45a9-8016-7cdf137eb050
md""" ### Septuagint glosses"""

# ╔═╡ cf50160a-3fd8-43c6-8f84-3a489f510a01
html"""
<br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/>
<hr/>
"""

# ╔═╡ ce7417e4-a6b5-40fa-934f-5a7790299817
md"""> # Mechanics"""

# ╔═╡ 97ffa639-474e-4cdd-980b-f15eafddbc76
md"""## Plotting data"""

# ╔═╡ ad428771-b930-41a6-ab3c-8344cf2fec98
md"""## Texts"""

# ╔═╡ 7d856b1e-9e60-4242-81a0-1695aa4c8ee0
targumlatinxmlcorpus = begin
	#reloadtext
	#readcitable(targumlatinxml, CtsUrn("urn:cts:compnov:bible.genesis.sept_latin:"), TEIDivAb, FileReader)
end

# ╔═╡ f1245ada-c035-4910-9b4a-26c06bbc6689
septlatinxmlcorpus = begin
	#reloadtext
	#readcitable(septlatinxml, CtsUrn("urn:cts:compnov:bible.genesis.sept_latin:"), TEIDivAb, FileReader)
end

# ╔═╡ d7f8ef2e-2297-49a2-a77a-4d94877edca0
srcurl = "https://raw.githubusercontent.com/neelsmith/compnov/main/corpus/compnov.cex"

# ╔═╡ d76fee5c-7adf-4799-84da-5195de6fdae1
corpus = fromcex(srcurl, CitableTextCorpus, UrlReader)

# ╔═╡ de29c0ec-1f77-40dd-bc38-a5ba34d352b3
repo = dirname(pwd())

# ╔═╡ cec7d5b0-df32-4924-94fd-05bf8b1e3b0f
septlatinxml = joinpath(repo, "editions", "septuagint_latin_genesis.xml")

# ╔═╡ d36b5b5f-88e2-4d2a-b448-63fb6ab9a433
targumlatinxml =  joinpath(repo, "editions", "targum_latin_genesis.xml")

# ╔═╡ e0696cff-38c1-4f66-944b-bbdecdaf28bd
md"""## Abbreviations"""

# ╔═╡ 3ed6915e-5849-4274-ba0c-811ed6f7d923
prefix = "http://www.tei-c.org/ns/1.0"

# ╔═╡ 1dc8dd59-62ac-4269-8190-417c14f9337a
"""Brute force collection of abbr/expan choices in a given XML node."""
function abbrsfornode(n::EzXML.Node)
	#findall("/tei:choice/tei:abbr", n,  ["tei" => "http://www.tei-c.org/ns/1.0"])
	string(n.name, " -> ", n.content)
	choices = filter(elements(n))  do el
		el.name == "choice"
	end
	pairs = []
	for c in choices
		kids = elements(c)
		abbr = filter(kids)  do el
			el.name == "abbr"
		end
		expan = filter(kids)  do el
			el.name == "expan"
		end
		push!(pairs, (abbr[1].content, expan[1].content))

	end
	pairs
end

# ╔═╡ bc17ab02-dd5c-4295-9eb1-20b6fb605ae9
md""" ### Targum"""

# ╔═╡ 4bbd5412-d4b4-4859-a198-5ed2c7fb4329
targumroot = root(readxml(targumlatinxml))

# ╔═╡ 53445d12-d194-48b2-a197-eb026f850e63
targumabs =  findall("//tei:ab", targumroot, ["tei" => "http://www.tei-c.org/ns/1.0"])

# ╔═╡ 415ba180-f6d4-4535-807d-a62b38d86daa
md"""Citable nodes in edition of Targum glossing: **$(targumabs |> length)**"""

# ╔═╡ f2ba7e2c-9dcc-4570-8809-94c8c88f4958
targumpairsraw = map(targumabs) do n
	abbrsfornode(n)
end

# ╔═╡ 1097618c-5dc3-4a81-9348-4a76eb7cfbef
targumpairs = filter(v -> ! isempty(v), targumpairsraw) |> Iterators.flatten |> collect

# ╔═╡ 5f05548c-b610-4d10-b316-db9e06cf85e3
length(targumpairs)

# ╔═╡ 017d5cc9-b2af-4bb6-8505-d7754ae0446c
targumabbrs = map(pr -> pr[1], targumpairs)

# ╔═╡ 573928a7-6059-4d1c-bbd0-c8beb6cd1c42
targumabbrcounts = countmap(targumabbrs) |> OrderedDict

# ╔═╡ b48a3dd8-03a4-42d7-b1bb-aca821746a66
targumabbrsorted = sort(targumabbrcounts, byvalue = true, rev = true)

# ╔═╡ f01aa87d-74fb-4e0f-93a1-79a14ad1be27
plt2x = collect(keys(targumabbrsorted))

# ╔═╡ 20b9e83f-e238-4628-9dac-0547e47a6a37
 plt2y = collect(values(targumabbrsorted))

# ╔═╡ 6cb6923f-de62-43fe-8be2-4babf3a41ab2
let
	layout2 = Layout(title = "Targum glosses: abbreviations")
	plt2 = bar(x = plt2x, y = plt2y)
	plot(plt2, layout2)
end
	

# ╔═╡ c17923cc-e839-4f9a-8fa5-70816d35b7b6
targumexpans = map(pr -> pr[2], targumpairs)

# ╔═╡ 0e620abd-a378-4fd5-a934-f5bab31a526a
targumexpancounts = countmap(targumexpans) |> OrderedDict

# ╔═╡ aa917ed9-5af5-49db-8787-a4022e601ba7
targumexpansorted = sort(targumexpancounts, byvalue = true, rev = true)

# ╔═╡ 841b9826-ebed-4330-8a3f-2f0e0b7f20d8
plt1x = collect(keys(targumexpansorted))

# ╔═╡ 1b33e0ec-ca70-4755-aeb9-019e96808949
 plt1y = collect(values(targumexpansorted))

# ╔═╡ 5a62bf6d-1d4b-402e-99e6-bddc910bcb0e
let
	layout1 = Layout(title = "Targum glosses: expansions")
	plt1 = bar(x = plt1x,y = plt1y)
	plot(plt1, layout1)
end
	

# ╔═╡ 576b1e5a-bd3b-49d9-9550-7596dfd50ff0
md"""### Septuagint glosses"""

# ╔═╡ 176a7db1-4d92-4539-9a6b-b99fd7d8d09b
lxxroot = root(readxml(septlatinxml))

# ╔═╡ c04478dc-c106-4df3-bfa8-e43d9498ddd0
lxxabs =  findall("//tei:ab", lxxroot, ["tei" => "http://www.tei-c.org/ns/1.0"])

# ╔═╡ ef32f17e-ff70-4165-8aca-7e7a334acf1e
md"""Citable nodes in edition of Septuagint glossing: **$(lxxabs |> length)**"""

# ╔═╡ f2e56ab2-5d30-4086-a262-be42e2f18c72
lxxpairsraw = map(lxxabs) do n
	abbrsfornode(n)
end

# ╔═╡ 6679d2d3-06aa-41ef-9fa3-3f53f716a1a8
lxxpairs = filter(v -> ! isempty(v), lxxpairsraw) |> Iterators.flatten |> collect

# ╔═╡ 853c5736-e307-4a79-a226-3da122e2b3b1
length(lxxpairs)

# ╔═╡ 49fc22d3-6fcf-4466-80df-c959d7412768
lxxabbrs = map(pr -> pr[1], lxxpairs)

# ╔═╡ 284b77d6-1bb8-4eb4-a826-9330b2b369dd
lxxabbrcounts = countmap(lxxabbrs) |> OrderedDict

# ╔═╡ 4512873c-e691-4f7b-85ef-1f3a1260718d
lxxabbrsorted = sort(lxxabbrcounts, byvalue = true, rev = true)

# ╔═╡ 673cf918-068b-4008-b235-8a41b0147963
plt4x = collect(keys(lxxabbrsorted))

# ╔═╡ 7a38df63-a823-46de-9a4a-4b3ec62a0d6c
plt4y = collect(values(lxxabbrsorted))

# ╔═╡ 30fad1b5-77ed-4918-95ec-7d29aa364caf
let
	layout4 = Layout(title = "Septuagint glosses: abbreviations")
	plt4= bar(x = plt4x, y = plt4y)
	plot(plt4, layout4)
end

# ╔═╡ 11b7460e-6383-4289-bd7c-8b68ae99d27a
lxxexpans = map(pr -> pr[2], lxxpairs)

# ╔═╡ d62d30e6-0d23-4620-a628-7e4460c896aa
lxxexpancounts = countmap(lxxexpans) |> OrderedDict

# ╔═╡ 7b5afba5-07a6-441a-874e-bd6e8939fc52
lxxexpansorted = sort(lxxexpancounts, byvalue = true, rev = true)

# ╔═╡ a23d6ebc-43c8-42c4-9d14-11f230475af1
plt3x = collect(keys(lxxexpansorted))  

# ╔═╡ 98f76ed0-57f8-4bc1-8c22-f0d4cfcc4c5e
plt3y = collect(values(lxxexpansorted))  

# ╔═╡ 8ead7286-3a7e-486d-8505-7b6651d577f1
let
	layout3 = Layout(title = "Septuagint glosses: expansions")
	plt3= bar(x = plt3x, y = plt3y)
	plot(plt3, layout3)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CitableBase = "d6f014bd-995c-41bd-9893-703339864534"
CitableCorpus = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
CitableTeiReaders = "b4325aa9-906c-402e-9c3f-19ab8a88308e"
CitableText = "41e66566-473b-49d4-85b7-da83b66615d8"
EzXML = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
LatinOrthography = "1e3032c9-fa1e-4efb-a2df-a06f238f6146"
OrderedCollections = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
Orthography = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
PlutoPlotly = "8e989ff0-3d88-8e9f-f020-2b208a939ff0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
CitableBase = "~10.4.0"
CitableCorpus = "~0.13.5"
CitableTeiReaders = "~0.10.3"
CitableText = "~0.16.2"
EzXML = "~1.2.0"
LatinOrthography = "~0.7.3"
OrderedCollections = "~1.6.3"
Orthography = "~0.22.0"
PlutoPlotly = "~0.4.6"
PlutoUI = "~0.7.59"
StatsBase = "~0.34.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.1"
manifest_format = "2.0"
project_hash = "6f793f8c62d47b188c332279510c5f1f436bd5bb"

[[deps.ANSIColoredPrinters]]
git-tree-sha1 = "574baf8110975760d391c710b6341da1afa48d8c"
uuid = "a4c015fc-c6ff-483c-b24f-f7ea428134e9"
version = "0.0.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

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

[[deps.BaseDirs]]
git-tree-sha1 = "cb25e4b105cc927052c2314f8291854ea59bf70a"
uuid = "18cc8868-cbac-4acf-b575-c8ff214dc66f"
version = "1.2.4"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "6c834533dc1fabd820c1db03c839bf97e45a3fab"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.14"

[[deps.CitableBase]]
deps = ["DocStringExtensions", "Documenter", "Test", "TestSetExtensions"]
git-tree-sha1 = "eec0c6a088940306a72f965fe5f9d81cda597d25"
uuid = "d6f014bd-995c-41bd-9893-703339864534"
version = "10.4.0"

[[deps.CitableCorpus]]
deps = ["CitableBase", "CitableText", "CiteEXchange", "DocStringExtensions", "Documenter", "HTTP", "Tables", "Test"]
git-tree-sha1 = "f400484e7b0fc1707f9dfd288fa297a4a2d9a2ad"
uuid = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
version = "0.13.5"

[[deps.CitableTeiReaders]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "DocStringExtensions", "Documenter", "EzXML", "HTTP", "Test"]
git-tree-sha1 = "deed5242dad324dfd619bdeaa23528e131664a91"
uuid = "b4325aa9-906c-402e-9c3f-19ab8a88308e"
version = "0.10.3"

[[deps.CitableText]]
deps = ["CitableBase", "DocStringExtensions", "Documenter", "Test", "TestSetExtensions"]
git-tree-sha1 = "00ddf4c75f3e2b8dd54a4e4808b8ec27053d9bb3"
uuid = "41e66566-473b-49d4-85b7-da83b66615d8"
version = "0.16.2"

[[deps.CiteEXchange]]
deps = ["CSV", "CitableBase", "DocStringExtensions", "Documenter", "HTTP", "Test"]
git-tree-sha1 = "da30bc6866a19e0235319c7fa3ffa6ab7f27e02e"
uuid = "e2e9ead3-1b6c-4e96-b95f-43e6ab899178"
version = "0.10.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "b8fe8546d52ca154ac556809e10c75e6e7430ac8"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.5"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "4b270d6465eb21ae89b732182c20dc165f8bf9f2"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.25.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

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
version = "1.1.0+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "ea32b83ca4fefa1768dc84e504cc0a94fb1ab8d1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.2"

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

[[deps.DeepDiffs]]
git-tree-sha1 = "9824894295b62a6a4ab6adf1c7bf337b3a9ca34c"
uuid = "ab62b9b5-e342-54a8-a765-a90f495de1a6"
version = "1.2.0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "35b66b6744b2d92c778afd3a88d2571875664a2a"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.4.2"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Documenter]]
deps = ["ANSIColoredPrinters", "AbstractTrees", "Base64", "CodecZlib", "Dates", "DocStringExtensions", "Downloads", "Git", "IOCapture", "InteractiveUtils", "JSON", "LibGit2", "Logging", "Markdown", "MarkdownAST", "Pkg", "PrecompileTools", "REPL", "RegistryInstances", "SHA", "TOML", "Test", "Unicode"]
git-tree-sha1 = "76deb8c15f37a3853f13ea2226b8f2577652de05"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "1.5.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c6317308b9dc757616f0b5cb379db10494443a7"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.2+0"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "380053d61bb9064d6aa4a9777413b40429c79901"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.2.0"

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

[[deps.Git]]
deps = ["Git_jll"]
git-tree-sha1 = "04eff47b1354d702c3a85e8ab23d539bb7d5957e"
uuid = "d7ba0133-e1db-5d97-8f8c-041e4b3a1eb2"
version = "1.3.1"

[[deps.Git_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "LibCURL_jll", "Libdl", "Libiconv_jll", "OpenSSL_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "d18fb8a1f3609361ebda9bf029b60fd0f120c809"
uuid = "f8c6e375-362e-5223-8a59-34ff63f689eb"
version = "2.44.0+2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "d1d712be3164d61d1fb98e7ce9bcbc6cc06b45ed"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.8"

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

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.LatinOrthography]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "DocStringExtensions", "Documenter", "Orthography", "Test"]
git-tree-sha1 = "b1578be26f15a1864afd88540babb3c53f3766fc"
uuid = "1e3032c9-fa1e-4efb-a2df-a06f238f6146"
version = "0.7.3"

[[deps.LazilyInitializedFields]]
git-tree-sha1 = "8f7f3cabab0fd1800699663533b6d5cb3fc0e612"
uuid = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
version = "1.2.2"

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

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

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

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MarkdownAST]]
deps = ["AbstractTrees", "Markdown"]
git-tree-sha1 = "465a70f0fc7d443a00dcdc3267a497397b8a3899"
uuid = "d0879d2d-cac2-40c8-9cee-1863dc0c7391"
version = "0.1.2"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

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

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a028ee3cb5641cccc4c24e90c36b0a4f7707bdf5"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.14+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Orthography]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "Compat", "DocStringExtensions", "Documenter", "OrderedCollections", "StatsBase", "Test", "TestSetExtensions", "TypedTables", "Unicode"]
git-tree-sha1 = "8012ec93b9f48c5b4aae0d59021f7f7b53100e8b"
uuid = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
version = "0.22.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlotlyBase]]
deps = ["ColorSchemes", "Dates", "DelimitedFiles", "DocStringExtensions", "JSON", "LaTeXStrings", "Logging", "Parameters", "Pkg", "REPL", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "56baf69781fc5e61607c3e46227ab17f7040ffa2"
uuid = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
version = "0.8.19"

[[deps.PlutoPlotly]]
deps = ["AbstractPlutoDingetjes", "BaseDirs", "Colors", "Dates", "Downloads", "HypertextLiteral", "InteractiveUtils", "LaTeXStrings", "Markdown", "Pkg", "PlotlyBase", "Reexport", "TOML"]
git-tree-sha1 = "1ae939782a5ce9a004484eab5416411c7190d3ce"
uuid = "8e989ff0-3d88-8e9f-f020-2b208a939ff0"
version = "0.4.6"

    [deps.PlutoPlotly.extensions]
    PlotlyKaleidoExt = "PlotlyKaleido"
    UnitfulExt = "Unitful"

    [deps.PlutoPlotly.weakdeps]
    PlotlyKaleido = "f2990250-8cf9-495f-b13a-cce12b45703c"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

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

[[deps.RegistryInstances]]
deps = ["LazilyInitializedFields", "Pkg", "TOML", "Tar"]
git-tree-sha1 = "ffd19052caf598b8653b99404058fce14828be51"
uuid = "2792f1a3-b283-48e8-9a74-f99dce5104f3"
version = "0.1.0"

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
git-tree-sha1 = "6bb314cb1aacfa37ef58e5a0ccf4a1ec0311f495"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.4"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

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

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TestSetExtensions]]
deps = ["DeepDiffs", "Distributed", "Test"]
git-tree-sha1 = "3a2919a78b04c29a1a57b05e1618e473162b15d0"
uuid = "98d24dd4-01ad-11ea-1b02-c9a08f80db04"
version = "2.0.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "60df3f8126263c0d6b357b9a1017bb94f53e3582"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.0"
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

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

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

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "52ff2af32e591541550bd753c0da8b9bc92bb9d9"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.12.7+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

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
# ╟─8637f512-3e4c-11ef-1819-4d43d3819374
# ╟─c042965c-5de9-4675-8852-703c49f6b8d5
# ╟─3e8ef72a-be16-40d4-8a84-9391e3eca5b8
# ╟─07b79a8a-b569-4ced-a495-f0528d3e6024
# ╟─6cb6923f-de62-43fe-8be2-4babf3a41ab2
# ╟─5a62bf6d-1d4b-402e-99e6-bddc910bcb0e
# ╟─98175044-9e89-45a9-8016-7cdf137eb050
# ╟─8ead7286-3a7e-486d-8505-7b6651d577f1
# ╟─30fad1b5-77ed-4918-95ec-7d29aa364caf
# ╟─cf50160a-3fd8-43c6-8f84-3a489f510a01
# ╟─ce7417e4-a6b5-40fa-934f-5a7790299817
# ╟─97ffa639-474e-4cdd-980b-f15eafddbc76
# ╠═841b9826-ebed-4330-8a3f-2f0e0b7f20d8
# ╠═1b33e0ec-ca70-4755-aeb9-019e96808949
# ╟─f01aa87d-74fb-4e0f-93a1-79a14ad1be27
# ╠═20b9e83f-e238-4628-9dac-0547e47a6a37
# ╠═a23d6ebc-43c8-42c4-9d14-11f230475af1
# ╠═98f76ed0-57f8-4bc1-8c22-f0d4cfcc4c5e
# ╠═673cf918-068b-4008-b235-8a41b0147963
# ╠═7a38df63-a823-46de-9a4a-4b3ec62a0d6c
# ╟─ad428771-b930-41a6-ab3c-8344cf2fec98
# ╟─7d856b1e-9e60-4242-81a0-1695aa4c8ee0
# ╟─f1245ada-c035-4910-9b4a-26c06bbc6689
# ╟─d7f8ef2e-2297-49a2-a77a-4d94877edca0
# ╟─d76fee5c-7adf-4799-84da-5195de6fdae1
# ╟─de29c0ec-1f77-40dd-bc38-a5ba34d352b3
# ╟─cec7d5b0-df32-4924-94fd-05bf8b1e3b0f
# ╟─d36b5b5f-88e2-4d2a-b448-63fb6ab9a433
# ╟─e0696cff-38c1-4f66-944b-bbdecdaf28bd
# ╟─3ed6915e-5849-4274-ba0c-811ed6f7d923
# ╟─1dc8dd59-62ac-4269-8190-417c14f9337a
# ╟─bc17ab02-dd5c-4295-9eb1-20b6fb605ae9
# ╟─4bbd5412-d4b4-4859-a198-5ed2c7fb4329
# ╟─53445d12-d194-48b2-a197-eb026f850e63
# ╟─415ba180-f6d4-4535-807d-a62b38d86daa
# ╟─f2ba7e2c-9dcc-4570-8809-94c8c88f4958
# ╟─1097618c-5dc3-4a81-9348-4a76eb7cfbef
# ╠═5f05548c-b610-4d10-b316-db9e06cf85e3
# ╟─017d5cc9-b2af-4bb6-8505-d7754ae0446c
# ╟─573928a7-6059-4d1c-bbd0-c8beb6cd1c42
# ╟─b48a3dd8-03a4-42d7-b1bb-aca821746a66
# ╟─c17923cc-e839-4f9a-8fa5-70816d35b7b6
# ╟─0e620abd-a378-4fd5-a934-f5bab31a526a
# ╟─aa917ed9-5af5-49db-8787-a4022e601ba7
# ╟─576b1e5a-bd3b-49d9-9550-7596dfd50ff0
# ╟─176a7db1-4d92-4539-9a6b-b99fd7d8d09b
# ╟─c04478dc-c106-4df3-bfa8-e43d9498ddd0
# ╟─ef32f17e-ff70-4165-8aca-7e7a334acf1e
# ╟─f2e56ab2-5d30-4086-a262-be42e2f18c72
# ╟─6679d2d3-06aa-41ef-9fa3-3f53f716a1a8
# ╟─853c5736-e307-4a79-a226-3da122e2b3b1
# ╟─49fc22d3-6fcf-4466-80df-c959d7412768
# ╟─284b77d6-1bb8-4eb4-a826-9330b2b369dd
# ╟─4512873c-e691-4f7b-85ef-1f3a1260718d
# ╟─11b7460e-6383-4289-bd7c-8b68ae99d27a
# ╟─d62d30e6-0d23-4620-a628-7e4460c896aa
# ╟─7b5afba5-07a6-441a-874e-bd6e8939fc52
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
