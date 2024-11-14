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

# ╔═╡ 05b28e80-5806-42ce-a033-6ae0e891c4e7
begin
	using Kanones, CitableParserBuilder
	using CitableBase, CitableCorpus, CitableText
	using Orthography, PolytonicGreek
	using Downloads

	using PlutoUI
	using HypertextLiteral
end


# ╔═╡ da29c982-8d5c-4a41-97cd-9faf05192df3
md"""*Unhide the preceding cell to see the Julia environment.*"""

# ╔═╡ d8ddc2fc-81cc-471a-a841-ca362a73e5f4
TableOfContents()

# ╔═╡ 85215242-f28c-11ee-109f-27540839bc37
md"""# Lemmatized search for functional alignment"""

# ╔═╡ 2fcd3b4a-cd44-41e3-b2ac-3a03e4dbce4d
ποιεω = "lsj.n84234"

# ╔═╡ 436d6abb-2726-46dc-90d7-2b26e7bd9e71
lexid = ποιεω

# ╔═╡ 6672774f-b5eb-4140-ad06-246d4fbd0da0
md"""*See counts for each form*: $(@bind listforms CheckBox())"""

# ╔═╡ a80f7fea-00cd-47fe-863f-9ff119a428eb
begin
	#allofthem = [displayalignment(f, corpus) for f in lemmapassages[showthisform]]
	#join(allofthem, "\n\n") |> Markdown.parse
end
	

# ╔═╡ 5a9506ae-d2ae-476b-80c5-c74cb2475d1f
html"""
<br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/>
"""

# ╔═╡ ad7b93d4-aaf6-4ade-8563-42741ab3b9b8
md"""> # Stuff you can ignore"""

# ╔═╡ eb29a5e8-800f-4bb4-b630-d7699d64b896
md"""> ## Displaying results"""

# ╔═╡ b49e002f-42c4-438d-9c84-8795c439fd20
function displayalignmenthtml(u,c,hilite)
	reduced = collapsePassageBy(u,1) |> dropversion
	vulg = filter(c.passages) do p
		dropversion(p.urn) == reduced && versionid(p.urn) == "vulgate"
	end
	tnch = filter(c.passages) do p
		dropversion(p.urn) == reduced && versionid(p.urn) == "masoretic"
	end
	onk = filter(c.passages) do p
		dropversion(p.urn) == reduced && versionid(p.urn) == "onkelos"
	end
	sept = filter(c.passages) do p
		dropversion(p.urn) == reduced && versionid(p.urn) == "septuagint"
	end
	replstring = replace(sept[1].text, hilite => """<span class="hilite">$(hilite)</span>""")

	
	report = """<p>Greek text of  $(titlecase(workid(reduced))) $(passagecomponent(reduced))
	</p>
	<blockquote>
		$(replstring)
	</blockquote>

	<p>Parallel passages:</p>
	<ul>
	
<li> <i>Hebrew Bible</i>: $(tnch[1].text) </li>
<li> <i>Vulgate</i>: $(vulg[1].text) </li>
<li> <i>Targum Onkelos</i>: $(onk[1].text)</li> 
	</ul>
	"""

end

# ╔═╡ 542bef3e-ce23-4b0f-9e01-8827bff33c30
function displayalignment(u, c)
	reduced = collapsePassageBy(u,1) |> dropversion
	vulg = filter(c.passages) do p
		dropversion(p.urn) == reduced && versionid(p.urn) == "vulgate"
	end
	tnch = filter(c.passages) do p
		dropversion(p.urn) == reduced && versionid(p.urn) == "masoretic"
	end
	onk = filter(c.passages) do p
		dropversion(p.urn) == reduced && versionid(p.urn) == "onkelos"
	end
	
	report = """Parallel passages for $(titlecase(workid(reduced))) $(passagecomponent(reduced))


	
- *Hebrew Bible*: $(tnch[1].text) 
- *Vulgate*: $(vulg[1].text) 
- *Targum Onkelos*: $(onk[1].text) 
"""
	report
end

# ╔═╡ 5725ebb6-0acb-4878-8d90-29b38c4b17ac
md"""> ## Lemmatized results"""

# ╔═╡ 457b89ac-c23b-4e46-aa48-a6b32794abcd
md"""> ## Labelling"""

# ╔═╡ 9d3073a3-195c-4d76-b0ed-d5f810e64878
idval = split(ποιεω, "." )[2]

# ╔═╡ fd900acb-af23-4ce0-be6a-e8c9e0e1e2df
lsjids = lemmatadict()

# ╔═╡ 160eefdd-6297-4db9-80ce-390ba639a940
lemmastring = lsjids[idval]

# ╔═╡ ad52a75d-aa8b-46a9-81ee-36d102e8a8fe
titlestring = string(lemmastring, " (", lexid, ")")

# ╔═╡ 4fd1b098-4745-4471-be33-e642da550142
md"""## Index for $(titlestring) """

# ╔═╡ 1f78961b-8a42-4d62-a638-460081f1bcc3
md"""> ## Parser"""

# ╔═╡ 55894f53-9de9-47d8-9a0d-3bfaa1f7e3f5
"""Download parser data from URN `u` and instantiate a DataFrame parser.""" 
function getremoteparser(u)
	tmp = Downloads.download(u)
	parser = dfParser(tmp)
	rm(tmp)
	parser
end

# ╔═╡ d0cac39e-2bde-442e-af09-1f0ffbdb6b10
parserurl = "http://shot.holycross.edu/morphology/comprehensive-current.csv"

# ╔═╡ 9f1b208f-95e4-4c40-85c6-e8ebc1716195
greekparser = getremoteparser(parserurl)

# ╔═╡ 6a69700f-3be3-44b8-81ef-db0fb0a30599
md"""> ## Text corpus"""

# ╔═╡ 870cc490-23cd-45d7-83c8-5b6f9ec7e089
srcurl = "https://raw.githubusercontent.com/neelsmith/compnov/main/corpus/compnov.cex"

# ╔═╡ ee3bab2d-5862-4bdd-a7bb-008a7da1a142
corpus = fromcex(srcurl, CitableTextCorpus, UrlReader)

# ╔═╡ e52ffa7c-c7c4-4e07-b3c3-17121d912898
sept = filter(corpus.passages) do psg
    versionid(psg.urn) == "septuagint" && workid(psg.urn) == "genesis"
end |> CitableTextCorpus

# ╔═╡ c37588bb-fdad-4d1f-9f19-68529fc59335
md"""> ## Tokenized edition and corpus lexicon"""

# ╔═╡ f85a1ab0-fc79-4785-9069-cc81d58cdbed
lg = literaryGreek()

# ╔═╡ d7faa389-b879-4b5a-969c-788094d158ef
greektknidx = corpusindex(sept, lg)

# ╔═╡ dc7d39d7-50a0-44df-abe0-4008b7d0026d
greektokenized = tokenize(sept,lg)

# ╔═╡ 1fd1c4cb-33d7-4567-9e3a-505ed4e4754a
greeklex = filter(greektokenized) do t
    t.tokentype isa LexicalToken
end 

# ╔═╡ deefb642-2a07-4ec4-b894-f58adb26472a
greektcorpus = map(t -> t.passage, greeklex) |> CitableTextCorpus

# ╔═╡ 37eb8eef-dc07-49b9-98c9-43694a3edd42
greekvocab = map(t -> t.passage.text, greeklex) |> unique

# ╔═╡ bf50a728-6a3f-4796-89d4-7cbc7b0c42d5
md"""> ## The lemmatized dictionary"""

# ╔═╡ 218b24e5-bb42-4999-a457-c39541282bba
greekparsedtokens = parsecorpus(greektcorpus, greekparser)

# ╔═╡ ff2a4c70-effc-4656-afd9-908e9b84d44e
lemmatizedgreekidx = lexemedictionary(greekparsedtokens.analyses, greektknidx)

# ╔═╡ 383b7946-47f6-4b27-a561-ebce1d1325b3
lemmapassages = lemmatizedgreekidx[ποιεω]

# ╔═╡ 0bdd5b87-82f8-4480-98a8-f161a9aa12ad
lemmaforms = lemmapassages |> keys |> collect

# ╔═╡ 7381370b-986d-4732-9466-604395905e49
md"""For $(titlestring), found $(length(lemmaforms)) distinct forms"""

# ╔═╡ 095738c8-cc11-4331-a60f-bf301cf25089
if listforms
	listitems = []
	for surfaceform in sort(lemmaforms)
		psgcount =  length(lemmapassages[surfaceform])
		item = psgcount == 1 ? "- $(surfaceform): 1 passage" : "- $(surfaceform): $(psgcount) passages"
		push!(listitems, item)
	end
	join(listitems,"\n") |> Markdown.parse
end

# ╔═╡ 4e88c3e0-8783-4057-8866-2e9f73baf918
md"""*See passages for a form*: $(@bind showthisform Select(sort(lemmaforms)))"""

# ╔═╡ 9f7f917a-64e9-4955-9326-2028bc70289d
length(lemmapassages[showthisform]) == 1 ?  
md"""#### 	1 passage for form $(showthisform)""" : md"""#### 	$(length(lemmapassages[showthisform])) passages for form $(showthisform)"""

# ╔═╡ 5d0c60c2-8a33-4cf1-8360-6cc9b0d69e6c
begin
	allofthehtml = [displayalignmenthtml(f, corpus, showthisform) for f in lemmapassages[showthisform]]
	join(allofthehtml, "\n\n")  |> HTML
end

# ╔═╡ e58197c9-8129-4e17-a96c-2f1f64901e6e
@htl """
<style>
	pluto-output {
		--julia-mono-font-stack: system-ui,sans-serif;
	}
	.hilite {
		background-color: yellow;
		font-weight: bold;
	}
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CitableBase = "d6f014bd-995c-41bd-9893-703339864534"
CitableCorpus = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
CitableParserBuilder = "c834cb9d-35b9-419a-8ff8-ecaeea9e2a2a"
CitableText = "41e66566-473b-49d4-85b7-da83b66615d8"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Kanones = "107500f9-53d4-4696-8485-0747242ad8bc"
Orthography = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PolytonicGreek = "72b824a7-2b4a-40fa-944c-ac4f345dc63a"

[compat]
CitableBase = "~10.3.1"
CitableCorpus = "~0.13.5"
CitableParserBuilder = "~0.25.1"
CitableText = "~0.16.2"
HypertextLiteral = "~0.9.5"
Kanones = "~0.24.1"
Orthography = "~0.21.3"
PlutoUI = "~0.7.58"
PolytonicGreek = "~0.21.11"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.6"
manifest_format = "2.0"
project_hash = "289cf797738e9f7e89eddfeccd6ef7fe18b14872"

[[deps.ANSIColoredPrinters]]
git-tree-sha1 = "574baf8110975760d391c710b6341da1afa48d8c"
uuid = "a4c015fc-c6ff-483c-b24f-f7ea428134e9"
version = "0.0.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0f748c81756f2e5e6854298f11ad8b2dfae6911a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.0"

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

[[deps.AtticGreek]]
deps = ["DocStringExtensions", "Documenter", "Orthography", "PolytonicGreek", "Test", "TestSetExtensions", "Unicode"]
git-tree-sha1 = "1a9970c7477056f7bf66326edfced5a4ac970e16"
uuid = "330c8319-f7ed-461a-8c52-cee5da4c0892"
version = "0.9.2"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "f1dff6729bc61f4d49e140da1af55dcd1ac97b2f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.5.0"

[[deps.BitFlags]]
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "a44910ceb69b0d44fe262dd451ab11ead3ed0be8"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.13"

[[deps.CitableBase]]
deps = ["DocStringExtensions", "Documenter", "Test", "TestSetExtensions"]
git-tree-sha1 = "cc4f1e1db392c4a05eb29026774d6f26ae8ca457"
uuid = "d6f014bd-995c-41bd-9893-703339864534"
version = "10.3.1"

[[deps.CitableCollection]]
deps = ["CSV", "CitableBase", "CitableObject", "CitableText", "CiteEXchange", "DocStringExtensions", "Documenter", "HTTP", "Tables", "Test", "TypedTables"]
git-tree-sha1 = "866abc4fb8ae2d3350a2ccd91f80a24b42e8343c"
uuid = "7b95b006-44c5-4794-afff-00ccebff52d7"
version = "0.4.6"

[[deps.CitableCorpus]]
deps = ["CitableBase", "CitableText", "CiteEXchange", "DocStringExtensions", "Documenter", "HTTP", "Tables", "Test"]
git-tree-sha1 = "f400484e7b0fc1707f9dfd288fa297a4a2d9a2ad"
uuid = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
version = "0.13.5"

[[deps.CitableObject]]
deps = ["CitableBase", "CiteEXchange", "DocStringExtensions", "Documenter", "Downloads", "Test", "TestSetExtensions"]
git-tree-sha1 = "86eb34cc98bc2c5b73dc96da5fe116adba903d56"
uuid = "e2b2f5ea-1cd8-4ce8-9b2b-05dad64c2a57"
version = "0.16.1"

[[deps.CitableParserBuilder]]
deps = ["CSV", "CitableBase", "CitableCorpus", "CitableObject", "CitableText", "Compat", "Dictionaries", "DocStringExtensions", "Documenter", "HTTP", "OrderedCollections", "Orthography", "StatsBase", "Test", "TestSetExtensions", "TypedTables"]
git-tree-sha1 = "8be86fb0193ebd8efb1c3a0dc147f62ff0893cf3"
uuid = "c834cb9d-35b9-419a-8ff8-ecaeea9e2a2a"
version = "0.25.1"

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
git-tree-sha1 = "59939d8a997469ee05c4b4944560a820f9ba0d73"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.4"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "c955881e3c981181362ae4088b35995446298b80"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.14.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "6cbbd4d241d7e6579ab354737f4dd95ca43946e1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.1"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "0f4b5d62a88d8f59003e43c25a8a90de9eb76317"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.18"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

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
git-tree-sha1 = "1f3b7b0d321641c1f2e519f7aed77f8e1f6cb133"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.29"

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
git-tree-sha1 = "4a40af50e8b24333b9ec6892546d9ca5724228eb"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "1.3.0"

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
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "9f00e42f8d99fdde64d40c8ea5d14269a2e2c1aa"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.21"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

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

[[deps.Glob]]
git-tree-sha1 = "97285bbd5230dd766e9ef6749b80fc617126d496"
uuid = "c27321d9-0574-5035-807b-f59d2c89b15c"
version = "1.3.1"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "8e59b47b9dc525b70550ca082ce85bcd7f5477cd"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.5"

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
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterableTables]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Requires", "TableTraits", "TableTraitsUtils"]
git-tree-sha1 = "70300b876b2cebde43ebc0df42bc8c94a144e1b4"
uuid = "1c8ee90f-4401-5389-894e-7a04a3dc0f4d"
version = "1.0.0"

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

[[deps.Kanones]]
deps = ["AtticGreek", "BenchmarkTools", "CSV", "CitableBase", "CitableCollection", "CitableCorpus", "CitableObject", "CitableParserBuilder", "CitableText", "Compat", "DataFrames", "Dates", "DelimitedFiles", "DocStringExtensions", "Documenter", "Downloads", "Glob", "HTTP", "Orthography", "PolytonicGreek", "Query", "Tables", "Test", "TestSetExtensions", "Unicode"]
git-tree-sha1 = "50c7e257d6430640123d1000967d5bf431759823"
uuid = "107500f9-53d4-4696-8485-0747242ad8bc"
version = "0.24.1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

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
git-tree-sha1 = "18144f3e9cbe9b15b070288eef858f71b291ce37"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.27"

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

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

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
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

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
git-tree-sha1 = "af81a32750ebc831ee28bdaaba6e1067decef51e"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.2"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3da7367955dcc5c54c1ba4d402ccdc09a1a3e046"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.13+1"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Orthography]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "Compat", "DocStringExtensions", "Documenter", "OrderedCollections", "StatsBase", "Test", "TestSetExtensions", "TypedTables", "Unicode"]
git-tree-sha1 = "a337b43561a8b40890720d21fc2b866424465129"
uuid = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
version = "0.21.3"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

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
git-tree-sha1 = "71a22244e352aa8c5f0f2adde4150f62368a3f2e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.58"

[[deps.PolytonicGreek]]
deps = ["Compat", "DocStringExtensions", "Documenter", "Orthography", "Test", "TestSetExtensions", "Unicode"]
git-tree-sha1 = "7a170c0bd173f1d29ceba2a349e8f0f499ad6e87"
uuid = "72b824a7-2b4a-40fa-944c-ac4f345dc63a"
version = "0.21.11"

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

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "88b895d13d53b5577fd53379d913b9ab9ac82660"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.Query]]
deps = ["DataValues", "IterableTables", "MacroTools", "QueryOperators", "Statistics"]
git-tree-sha1 = "a66aa7ca6f5c29f0e303ccef5c8bd55067df9bbe"
uuid = "1a8c2f83-1ff3-5112-b086-8aa67b057ba1"
version = "1.0.0"

[[deps.QueryOperators]]
deps = ["DataStructures", "DataValues", "IteratorInterfaceExtensions", "TableShowUtils"]
git-tree-sha1 = "911c64c204e7ecabfd1872eb93c49b4e7c701f02"
uuid = "2aef5ad7-51ca-5a8f-8e88-e75cf067b44b"
version = "0.9.3"

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
git-tree-sha1 = "0e7508ff27ba32f26cd459474ca2ede1bc10991f"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.1"

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

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableShowUtils]]
deps = ["DataValues", "Dates", "JSON", "Markdown", "Unicode"]
git-tree-sha1 = "2a41a3dedda21ed1184a47caab56ed9304e9a038"
uuid = "5e66a065-1f0a-5976-b372-e0b8c017ca10"
version = "0.2.6"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.TableTraitsUtils]]
deps = ["DataValues", "IteratorInterfaceExtensions", "Missings", "TableTraits"]
git-tree-sha1 = "78fecfe140d7abb480b53a44f3f85b6aa373c293"
uuid = "382cd787-c1b6-5bf2-a167-d5b971a19bda"
version = "1.0.2"

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

[[deps.TestSetExtensions]]
deps = ["DeepDiffs", "Distributed", "Test"]
git-tree-sha1 = "3a2919a78b04c29a1a57b05e1618e473162b15d0"
uuid = "98d24dd4-01ad-11ea-1b02-c9a08f80db04"
version = "2.0.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "71509f04d045ec714c4748c785a59045c3736349"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.7"
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
# ╟─05b28e80-5806-42ce-a033-6ae0e891c4e7
# ╟─da29c982-8d5c-4a41-97cd-9faf05192df3
# ╟─d8ddc2fc-81cc-471a-a841-ca362a73e5f4
# ╟─85215242-f28c-11ee-109f-27540839bc37
# ╟─2fcd3b4a-cd44-41e3-b2ac-3a03e4dbce4d
# ╟─436d6abb-2726-46dc-90d7-2b26e7bd9e71
# ╟─4fd1b098-4745-4471-be33-e642da550142
# ╟─7381370b-986d-4732-9466-604395905e49
# ╟─6672774f-b5eb-4140-ad06-246d4fbd0da0
# ╟─095738c8-cc11-4331-a60f-bf301cf25089
# ╟─9f7f917a-64e9-4955-9326-2028bc70289d
# ╟─4e88c3e0-8783-4057-8866-2e9f73baf918
# ╟─5d0c60c2-8a33-4cf1-8360-6cc9b0d69e6c
# ╟─a80f7fea-00cd-47fe-863f-9ff119a428eb
# ╟─5a9506ae-d2ae-476b-80c5-c74cb2475d1f
# ╟─ad7b93d4-aaf6-4ade-8563-42741ab3b9b8
# ╟─eb29a5e8-800f-4bb4-b630-d7699d64b896
# ╟─b49e002f-42c4-438d-9c84-8795c439fd20
# ╟─542bef3e-ce23-4b0f-9e01-8827bff33c30
# ╟─5725ebb6-0acb-4878-8d90-29b38c4b17ac
# ╟─0bdd5b87-82f8-4480-98a8-f161a9aa12ad
# ╟─383b7946-47f6-4b27-a561-ebce1d1325b3
# ╟─457b89ac-c23b-4e46-aa48-a6b32794abcd
# ╠═ad52a75d-aa8b-46a9-81ee-36d102e8a8fe
# ╠═9d3073a3-195c-4d76-b0ed-d5f810e64878
# ╠═160eefdd-6297-4db9-80ce-390ba639a940
# ╠═fd900acb-af23-4ce0-be6a-e8c9e0e1e2df
# ╟─1f78961b-8a42-4d62-a638-460081f1bcc3
# ╟─55894f53-9de9-47d8-9a0d-3bfaa1f7e3f5
# ╟─d0cac39e-2bde-442e-af09-1f0ffbdb6b10
# ╠═9f1b208f-95e4-4c40-85c6-e8ebc1716195
# ╟─6a69700f-3be3-44b8-81ef-db0fb0a30599
# ╟─870cc490-23cd-45d7-83c8-5b6f9ec7e089
# ╟─ee3bab2d-5862-4bdd-a7bb-008a7da1a142
# ╟─e52ffa7c-c7c4-4e07-b3c3-17121d912898
# ╟─c37588bb-fdad-4d1f-9f19-68529fc59335
# ╟─f85a1ab0-fc79-4785-9069-cc81d58cdbed
# ╟─d7faa389-b879-4b5a-969c-788094d158ef
# ╟─dc7d39d7-50a0-44df-abe0-4008b7d0026d
# ╟─1fd1c4cb-33d7-4567-9e3a-505ed4e4754a
# ╟─deefb642-2a07-4ec4-b894-f58adb26472a
# ╟─37eb8eef-dc07-49b9-98c9-43694a3edd42
# ╟─bf50a728-6a3f-4796-89d4-7cbc7b0c42d5
# ╟─ff2a4c70-effc-4656-afd9-908e9b84d44e
# ╟─218b24e5-bb42-4999-a457-c39541282bba
# ╠═e58197c9-8129-4e17-a96c-2f1f64901e6e
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
