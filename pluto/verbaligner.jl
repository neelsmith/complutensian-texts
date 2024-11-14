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

# ╔═╡ f82ebfde-453c-4e47-bfeb-df73c7633059
begin
	# Tabulae must be version 0.10 or higher.
	using Tabulae
	using CitableParserBuilder
	using CitableBase
	using CitableText
	using CitableCorpus
	using CitableTeiReaders
	using EditionBuilders

	using Orthography, LatinOrthography

	using Downloads
	using HypertextLiteral

	using PlutoUI
	md"""*Unhide this cell to see Julia package versions*."""
end

# ╔═╡ e4ab310c-a9aa-4ee6-854a-4935c27e6288
TableOfContents()

# ╔═╡ 6568f1e0-2da5-11ef-27df-5f07fa823895
md"""# Align verbs in parallel passages"""

# ╔═╡ a04059ac-04d8-4ed8-a476-fd0231323783
@bind reloadtext Button("Reload text")

# ╔═╡ afb29d3a-55f6-40d6-ba47-99765cfe4a7a
function mdlist(v)
	join(v, ", ")
end

# ╔═╡ 2e8e15ae-f0f6-4b22-a963-33570fcc5180
html"""
<br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/>
"""

# ╔═╡ b53c4198-35f0-4f6b-a58e-20b6aee44e98
md"""> # Things you can skip"""

# ╔═╡ 20bcdb8e-27d6-46b1-bedd-1caf625a2e6e
md"""> ## Skip tokens"""

# ╔═╡ bad510e7-19be-4e2e-8279-ba6252fe2f9d
genA = joinpath(pwd() |> dirname, "notes", "verbs-gen1-16.cex") |> read |> String

# ╔═╡ eda291f3-24bf-4865-96f3-6ca470a82624
genAdatalines = filter(ln -> ! isempty(ln), split(genA,"\n")[2:end])

# ╔═╡ c295820e-7185-447a-82c5-5cc9d07c3369
	genAskipcol = map(genAdatalines) do ln
		split(ln,"|")[3]
	end

# ╔═╡ d478cf0d-d303-4682-b3a9-f1338d2a8dce
skiplist = filter(ln -> ! isempty(ln), genAskipcol) |> unique


# ╔═╡ 713065c4-9d98-4e10-90cf-5f3c62023fa8
md"""> ## Aligning passages"""

# ╔═╡ ec75a412-68be-42ba-8219-46e6a0dc73ad
md"""> ## Tokenization and parsing"""

# ╔═╡ 14949ae5-9993-46ea-8f63-28c04fbfa86c
ortho23 = latin23()

# ╔═╡ 300a8a69-049b-45a3-8d5a-d8c6fd6bfcca
ortho25 = latin25()

# ╔═╡ 77bde32d-a14a-4528-8e9f-6cbe4c168f8e
"""True if analysis has a verb form."""
function verbform(a::Analysis)
	latform = latinForm(a)
	latform isa LMFFiniteVerb ||
	latform isa LMFInfinitive ||
	latform isa LMFParticiple 
end

# ╔═╡ 3576848a-b0b3-4643-928a-5da897fd7265
"""Retrieve texts from corpus."""
function retrieve(u::CtsUrn, c::CitableTextCorpus)
	if isrange(u)
		"Not handling rnges yet."
	else
		psgref = passagecomponent(u)
		dotted = psgref * "."
		
		filter(c.passages) do psg
			checkref = passagecomponent(psg.urn) 
			groupid(psg.urn) == groupid(u) &&
			workid(psg.urn) == workid(u) &&
			(psgref == checkref || startswith(checkref, dotted) )
		end
	end
end

# ╔═╡ 83ef729d-125c-41d6-9030-dc5d829f8116
"""Extract verb forms from a passage"""
function retrieveverbs(psg, corpus, ortho, parser; stoplist = skiplist)
	psglist = retrieve(psg, corpus)
	results = []
	for p in psglist
		for t in tokenize(p, ortho)	
			txtval = text(passage(t))
			if txtval in stoplist
				# skip it
			else
				parses = parsetoken(txtval, parser)
				if isempty(parses)
				elseif verbform(parses[1])
					push!(results, parses[1] |> token)
				end
			end
		end
	end
	results
end

# ╔═╡ 9294ef16-705b-494e-96e5-f32e4f4d6491
md"""> ## Text corpus"""

# ╔═╡ 0ab274df-d0d3-4dab-9f87-252bfd71e811
md"""### Septuagint glossses"""

# ╔═╡ 5b876552-d296-4a12-87fe-65779766bbc4
repo = dirname(pwd())

# ╔═╡ 2c583f26-39b3-4e91-8735-698d27c4b468
septlatinxml = joinpath(repo, "editions", "septuagint_latin_genesis.xml")

# ╔═╡ 6e53ea39-55e4-476f-a31e-afbbaae31f92
septlatinxmlcorpus = begin
	reloadtext
	readcitable(septlatinxml, CtsUrn("urn:cts:compnov:bible.genesis.sept_latin:"), TEIDivAb, FileReader)
end

# ╔═╡ d217a173-5901-4f5d-a542-1494d317a951
lxxbldr = normalizedbuilder(; versionid = "lxxlatinnormed")

# ╔═╡ 04bede56-1d54-404c-9fce-fda47cb309f2
septlatin = edited(lxxbldr, septlatinxmlcorpus)

# ╔═╡ bb83b83c-16bb-4fab-a42d-aa5df38e9a53
psgreff = map(psg -> dropversion(urn(psg)), septlatin.passages)

# ╔═╡ 67ba6669-d248-4224-a29c-16ab450e1978
md""" ### Targum glosses"""

# ╔═╡ 31b85560-1933-4935-9ab0-a3cc91564c3e
targumlatinxml =  joinpath(repo, "editions", "targum_latin_genesis.xml")

# ╔═╡ e85e45de-5f66-4c6f-a8d4-64c61187f701
targbldr = normalizedbuilder(; versionid = "targumlatinnormed")

# ╔═╡ 27557198-c030-438a-9f56-cfdecbe0bd4a
targumlatinxmlcorpus = begin
	reloadtext
	readcitable(targumlatinxml, CtsUrn("urn:cts:compnov:bible.genesis.sept_latin:"), TEIDivAb, FileReader)
end

# ╔═╡ 0137579d-0be0-423b-98da-1965c17ae7ca
targumlatin = edited(targbldr, targumlatinxmlcorpus)

# ╔═╡ fa00482b-fae8-44f6-8012-4a9428a793c2
md""" ### Vulgate"""

# ╔═╡ 0f5274c4-5bee-419d-8460-d660670e8ba6
srcurl = "https://raw.githubusercontent.com/neelsmith/compnov/main/corpus/compnov.cex"

# ╔═╡ 800b981e-377d-4466-81bf-0c1bff1776d5
corpus = fromcex(srcurl, CitableTextCorpus, UrlReader)

# ╔═╡ 2d238610-add6-481c-8594-ab3e3598e3d9
vulgate = filter(corpus.passages) do psg
	versionid(psg.urn) == "vulgate"
end |> CitableTextCorpus

# ╔═╡ beb900e8-326b-4afd-bdbc-b44720af18e7
md"""> ## Build parsers"""

# ╔═╡ 29b840c3-7976-4e25-955b-cc2f2516d0bd
p23url = "http://shot.holycross.edu/tabulae/medieval-lat23-current.cex"

# ╔═╡ 264c7e8b-d738-4928-b6e8-670d00152295
p25url = "http://shot.holycross.edu/tabulae/medieval-lat25-current.cex"

# ╔═╡ cb147cb4-b577-4d2a-967f-2280fa50c3cb
parser23 = tabulaeStringParser(p23url, UrlReader)

# ╔═╡ d7dcc396-a176-47c7-afbf-87b9336d2ee2
testout = retrieveverbs(psgreff[6], septlatin, ortho23, parser23)

# ╔═╡ df3841db-64ff-493d-81ee-1aa9360828b3
parser25 = tabulaeStringParser(p25url, UrlReader)

# ╔═╡ 274afe87-7e6d-4884-9503-db08e468ee88
function verbsets(psgref::CtsUrn)
	@info("Get verbs for $(psgref)")
	(
	septlatin = retrieveverbs(psgref, septlatin, ortho23, parser23),
	targumlatin = retrieveverbs(psgref, targumlatin, ortho23, parser23),
	vulgate = retrieveverbs(psgref, vulgate, ortho25, parser25),
	
	
	)
end

# ╔═╡ cf1a781b-4be7-43de-9b44-a0dbee1a5bc9
allverbsets = map(p -> verbsets(p), psgreff)

# ╔═╡ 0c6ab1ee-b367-4512-bd7c-e1fdef5e97f6
begin
	mdlines = [
		"|Ref | LXX glosses | Targum glosses | Vulgate | Aligned |",
		"| --- | --- | --- | --- | --- |"
		
	]
	for (i,vset) in enumerate(allverbsets)
		ref = psgreff[i] |> passagecomponent
		aligned = length(vset.septlatin) == length(vset.targumlatin) == length(vset.vulgate)
		amark = aligned ? "✅" : "❌"
		
		data = [ref, mdlist(vset.septlatin), mdlist(vset.targumlatin),mdlist(vset.vulgate), amark]
		push!(mdlines, "| " * join(data, " | "), " |")
		
	end

	join(mdlines,"\n") |> Markdown.parse
	
end

# ╔═╡ 325e8cc2-1df1-4f26-a9bd-d08745a533d9
allverbsets[2].septlatin

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CitableBase = "d6f014bd-995c-41bd-9893-703339864534"
CitableCorpus = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
CitableParserBuilder = "c834cb9d-35b9-419a-8ff8-ecaeea9e2a2a"
CitableTeiReaders = "b4325aa9-906c-402e-9c3f-19ab8a88308e"
CitableText = "41e66566-473b-49d4-85b7-da83b66615d8"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
EditionBuilders = "2fb66cca-c1f8-4a32-85dd-1a01a9e8cd8f"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LatinOrthography = "1e3032c9-fa1e-4efb-a2df-a06f238f6146"
Orthography = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Tabulae = "a03c184b-2b42-4641-ae65-f14a9f5424c6"

[compat]
CitableBase = "~10.4.0"
CitableCorpus = "~0.13.5"
CitableParserBuilder = "~0.29.0"
CitableTeiReaders = "~0.10.3"
CitableText = "~0.16.2"
EditionBuilders = "~0.8.5"
HypertextLiteral = "~0.9.5"
LatinOrthography = "~0.7.3"
Orthography = "~0.22.0"
PlutoUI = "~0.7.59"
Tabulae = "~0.11.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.6"
manifest_format = "2.0"
project_hash = "acbef897e192a27103ffb7b45f01f31caa0a8bb7"

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

[[deps.BitFlags]]
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

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

[[deps.CitableObject]]
deps = ["CitableBase", "CiteEXchange", "DocStringExtensions", "Documenter", "Downloads", "Test", "TestSetExtensions"]
git-tree-sha1 = "86eb34cc98bc2c5b73dc96da5fe116adba903d56"
uuid = "e2b2f5ea-1cd8-4ce8-9b2b-05dad64c2a57"
version = "0.16.1"

[[deps.CitableParserBuilder]]
deps = ["CSV", "CitableBase", "CitableCorpus", "CitableObject", "CitableText", "Compat", "DataFrames", "Dictionaries", "DocStringExtensions", "Documenter", "Downloads", "OrderedCollections", "Orthography", "StatsBase", "Test", "TestSetExtensions", "TypedTables"]
git-tree-sha1 = "fbce105543993f657c2a6a18d98e640eed3bbc70"
uuid = "c834cb9d-35b9-419a-8ff8-ecaeea9e2a2a"
version = "0.29.0"

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
git-tree-sha1 = "5461b2a67beb9089980e2f8f25145186b6d34f91"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "1.4.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EditionBuilders]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "DocStringExtensions", "Documenter", "EzXML", "Test"]
git-tree-sha1 = "2934d7babf1127b7e8ef380de231b9683893aa49"
uuid = "2fb66cca-c1f8-4a32-85dd-1a01a9e8cd8f"
version = "0.8.5"

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

[[deps.Glob]]
git-tree-sha1 = "97285bbd5230dd766e9ef6749b80fc617126d496"
uuid = "c27321d9-0574-5035-807b-f59d2c89b15c"
version = "1.3.1"

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

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

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

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "66b20dd35966a748321d3b2537c4584cf40387c7"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.2"

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
git-tree-sha1 = "90b4f68892337554d31cdcdbe19e48989f26c7e6"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.3"

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

[[deps.Tabulae]]
deps = ["CitableBase", "CitableCorpus", "CitableObject", "CitableParserBuilder", "CitableText", "Compat", "DocStringExtensions", "Documenter", "Downloads", "Glob", "LatinOrthography", "Markdown", "Orthography", "Test", "TestSetExtensions", "Unicode"]
git-tree-sha1 = "1405e6b3f0080f373c97572fa192e52e2dfaeb4a"
uuid = "a03c184b-2b42-4641-ae65-f14a9f5424c6"
version = "0.11.1"

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
# ╟─f82ebfde-453c-4e47-bfeb-df73c7633059
# ╟─e4ab310c-a9aa-4ee6-854a-4935c27e6288
# ╟─6568f1e0-2da5-11ef-27df-5f07fa823895
# ╟─a04059ac-04d8-4ed8-a476-fd0231323783
# ╠═0c6ab1ee-b367-4512-bd7c-e1fdef5e97f6
# ╠═325e8cc2-1df1-4f26-a9bd-d08745a533d9
# ╠═afb29d3a-55f6-40d6-ba47-99765cfe4a7a
# ╟─2e8e15ae-f0f6-4b22-a963-33570fcc5180
# ╟─b53c4198-35f0-4f6b-a58e-20b6aee44e98
# ╟─20bcdb8e-27d6-46b1-bedd-1caf625a2e6e
# ╟─bad510e7-19be-4e2e-8279-ba6252fe2f9d
# ╠═eda291f3-24bf-4865-96f3-6ca470a82624
# ╟─c295820e-7185-447a-82c5-5cc9d07c3369
# ╟─d478cf0d-d303-4682-b3a9-f1338d2a8dce
# ╟─713065c4-9d98-4e10-90cf-5f3c62023fa8
# ╠═cf1a781b-4be7-43de-9b44-a0dbee1a5bc9
# ╟─274afe87-7e6d-4884-9503-db08e468ee88
# ╟─ec75a412-68be-42ba-8219-46e6a0dc73ad
# ╟─14949ae5-9993-46ea-8f63-28c04fbfa86c
# ╠═300a8a69-049b-45a3-8d5a-d8c6fd6bfcca
# ╟─d7dcc396-a176-47c7-afbf-87b9336d2ee2
# ╟─77bde32d-a14a-4528-8e9f-6cbe4c168f8e
# ╟─83ef729d-125c-41d6-9030-dc5d829f8116
# ╟─3576848a-b0b3-4643-928a-5da897fd7265
# ╟─bb83b83c-16bb-4fab-a42d-aa5df38e9a53
# ╟─9294ef16-705b-494e-96e5-f32e4f4d6491
# ╟─0ab274df-d0d3-4dab-9f87-252bfd71e811
# ╠═5b876552-d296-4a12-87fe-65779766bbc4
# ╟─2c583f26-39b3-4e91-8735-698d27c4b468
# ╟─6e53ea39-55e4-476f-a31e-afbbaae31f92
# ╟─d217a173-5901-4f5d-a542-1494d317a951
# ╟─04bede56-1d54-404c-9fce-fda47cb309f2
# ╟─67ba6669-d248-4224-a29c-16ab450e1978
# ╟─31b85560-1933-4935-9ab0-a3cc91564c3e
# ╟─e85e45de-5f66-4c6f-a8d4-64c61187f701
# ╟─27557198-c030-438a-9f56-cfdecbe0bd4a
# ╟─0137579d-0be0-423b-98da-1965c17ae7ca
# ╟─fa00482b-fae8-44f6-8012-4a9428a793c2
# ╟─0f5274c4-5bee-419d-8460-d660670e8ba6
# ╠═800b981e-377d-4466-81bf-0c1bff1776d5
# ╟─2d238610-add6-481c-8594-ab3e3598e3d9
# ╟─beb900e8-326b-4afd-bdbc-b44720af18e7
# ╟─29b840c3-7976-4e25-955b-cc2f2516d0bd
# ╟─264c7e8b-d738-4928-b6e8-670d00152295
# ╠═cb147cb4-b577-4d2a-967f-2280fa50c3cb
# ╠═df3841db-64ff-493d-81ee-1aa9360828b3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
