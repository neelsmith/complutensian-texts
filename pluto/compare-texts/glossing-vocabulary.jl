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

# ╔═╡ 505e5234-c399-11ee-2a14-bfee14a8bf57
begin
	using Orthography
	using LatinOrthography
	using CitableText
	using CitableCorpus
	using CitableBase
	using CitableTeiReaders
	using EditionBuilders

	using Downloads
	using HypertextLiteral

	using PlutoUI
	md"""*Unhide this cell to see the Julia environment.*"""
end

# ╔═╡ 01cd9b04-4308-4776-ad22-bcd4eb48a966
md"""*Noteboook version*: **1.0.2** *See version info*: $(@bind versioninfo CheckBox())"""

# ╔═╡ e38b36cc-af33-43df-804d-f65017a84888
if versioninfo
md"""

- **1.0.2**: use curated list of book IDs from gh repo
- **1.0.1**: works with new URNs
- **1.0.0**: initial release
"""
end

# ╔═╡ 3c108481-0a07-4849-a973-5384d7a4bfcb
TableOfContents()

# ╔═╡ 36dd1391-3550-4c87-8ba8-4325e007316a
md"""> This notebook lets you compare the Latin text of the Vulgate with the Latin text of the glossing commentary on the Septuagint in the Complutensis. For reference, it juxtaposes the Greek text of the Septuagint.
"""

# ╔═╡ f56c3f61-cae0-4d1a-b755-86ddff6d3c53
"""
<blockquote><p>Terms not found in the comparison text are <span class="hilite">highlighted</span>.</p></blockquote>
""" |> HTML

# ╔═╡ a2171ec8-6691-4f52-b9ec-a6281594d4b2
@bind reloadtext Button("Reload edition of glossing text")

# ╔═╡ ecbcee9e-9719-4883-8615-20a1602014a6
md"""# Compare vocabulary of glossing in the Complutensis"""

# ╔═╡ b873d268-5af3-4d6c-a1b7-3af6f3c764bf
html"""
<br/><br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/><br/>
"""

# ╔═╡ 2a25ecca-558a-46eb-b6a9-7c2ec76a066f
md"""> #  Mechanics"""

# ╔═╡ cf9ebba5-d90c-42ae-8a11-bdef4660991c
md"""> ## Token lists"""

# ╔═╡ 80e36d02-a7a0-4b18-9cf7-b26bbcadc345
vulgateortho = latin24()

# ╔═╡ 1d7b8019-0a2f-42ab-a2f4-ff53d266e1ae
"""Get lower case vocab list for a list of passages."""
function wordlist(tkns)
	map(tkns) do tkn
		lowercase(tkn.passage.text )
	end
end

# ╔═╡ ba2247ab-6b07-4230-9661-5cc9a17bed66
"""Format tokens in psg1 for display. Apply hilighting if a token is absent from list of tokens in psg2.
"""
function formatdiff(psg1, psg2)
	checklist = wordlist(psg2) |> unique
	tokenlist = map(psg1) do tkn
		if tkn.tokentype isa LexicalToken
			if lowercase(tkn.passage.text) in checklist
				" " * tkn.passage.text
			else
				" <span class=\"hilite\">" * tkn.passage.text * "</span>"
			end
		else
			tkn.passage.text
		end
	end
	"<p>" * join(tokenlist,"") * "</p>"

end

# ╔═╡ 5cf92532-b67a-40a3-ad1a-c7f03cdb0eda
md"""> ## Load texts

"""

# ╔═╡ cb77fe26-a3c9-48f9-8364-c6288ffd50d5
srcurl = "https://raw.githubusercontent.com/neelsmith/compnov/main/corpus/compnov.cex"

# ╔═╡ 1c27264c-cb66-4f0f-89ad-8d151a60bd58
corpus = fromcex(srcurl, CitableTextCorpus, UrlReader)

# ╔═╡ b049d8ff-6092-4174-9bc8-3138bd272eaf
vulgate = filter(corpus.passages) do psg
	versionid(psg.urn) == "vulgate"
end |> CitableTextCorpus

# ╔═╡ 9f98852b-acf8-4740-92c5-00e291d2943c
vulgatetkns = tokenize(vulgate, vulgateortho)

# ╔═╡ a538cd79-f58f-44d0-b4b3-413461084ff9
septuagint = filter(corpus.passages) do psg
	versionid(psg.urn) == "septuagint"
end |> CitableTextCorpus

# ╔═╡ 43f6d597-11ee-4faf-8710-964ca97b2c89
targum = filter(corpus.passages) do psg
	versionid(psg.urn) == "onkelos"
end |> CitableTextCorpus

# ╔═╡ ed6016b0-ebba-4403-b6e7-697e8a36e719
md"""> ## Menus for user selection of passages"""

# ╔═╡ bb72f016-3098-4814-a2ff-1705bf938a6f
begin
	booksurl = "https://raw.githubusercontent.com/neelsmith/compnov/main/corpus/bookslist.txt"
	tmp = Downloads.download(booksurl)
	workids = readlines(tmp)
	rm(tmp)
end

# ╔═╡ 571bfd40-3fc5-40ed-beb1-7035e25cf5bc
md"""
*Book*: $(@bind book Select(workids)) 
""" 

# ╔═╡ 0681c83f-f445-460e-891c-2d55ff54d918
"""Find unique list of chapter values for given book in a corpus."""
function chaptersforbook(corpus, bookid)
	bookpassages = filter(corpus.passages) do psg
		workid(psg.urn) == bookid
	end
	map(bookpassages) do psg
		collapsePassageTo(psg.urn, 1) |> passagecomponent
		
	end |> unique
		
end

# ╔═╡ 77bbc155-3d5d-4941-9188-d664e45e2d81
md"""*Chapter* $(@bind chap Select(chaptersforbook(vulgate, book)))"""

# ╔═╡ c1791f30-a4ef-409c-86ce-80708df51291
"""Find unique list of verse values for given book and chapter in a corpus."""
function versesforchapter(c, bk, chptr)
	chapterpassages = filter(c.passages) do psg
		psgchapter = collapsePassageTo(psg.urn, 1) |> passagecomponent
		workid(psg.urn) == bk && psgchapter == chptr
	end
	map(chapterpassages) do psg
		passagecomponent(psg.urn)
	end
end

# ╔═╡ 9aca0d5f-f4ed-44a6-8470-1d0e91b006eb
 md"""*Verse* $(@bind verse Select(versesforchapter(vulgate, book, chap)))"""

# ╔═╡ 7d035d8d-7f3c-4b1d-9eb9-2069f317109e
md"""### *$(titlecase(book))*  $(verse)
"""

# ╔═╡ 73919628-120d-4317-ba7b-26e74d2d75d9
md"""> Gather tokens for selected passage
"""

# ╔═╡ c2379250-5def-4e3e-b310-739c7e1b1587
vulgatepsg = filter(vulgatetkns) do tkn
	passagebase = verse * "."
	workid(tkn.passage.urn) == book &&
	startswith(passagecomponent(tkn.passage.urn), passagebase)
end

# ╔═╡ 22e0f5ff-d3c7-4450-a968-1165aefc1caa
septuagintpsg =  filter(septuagint.passages) do psg	
	workid(psg.urn) == book &&
	passagecomponent(psg.urn) == verse
end


# ╔═╡ 09556565-5d85-4684-a476-640aa025bf70
targumpsg =  filter(targum.passages) do psg	
	workid(psg.urn) == book &&
	passagecomponent(psg.urn) == verse
end

# ╔═╡ e2fa65bd-9084-4ce9-805e-9b1565bb5794


# ╔═╡ c2fbb1d6-a63f-47ef-9f5d-fc98fb4f5f5a
md"""> ## Load XML edition of Latin glosses on Septuagint."""

# ╔═╡ 1eabb81f-291a-4701-ab71-5eaaa8f03693
bldr = diplomaticbuilder(; versionid = "lxxlatinnormed")

# ╔═╡ a9592b4a-3db9-485e-a087-32786d584b1f
# ╠═╡ disabled = true
#=╠═╡

  ╠═╡ =#

# ╔═╡ 50966a9c-b83a-42c2-94b2-a1899fe51f12
md"""> ## Load glossing text data"""

# ╔═╡ 13825cdf-a2da-4be9-8052-80a86adf024c
repo = dirname(pwd()) |> dirname

# ╔═╡ 049e6845-f4e8-4223-a69d-8fbb877e98de
septlatinxml = joinpath(repo, "editions", "septuagint_latin_genesis.xml")

# ╔═╡ 7f933451-896a-48a9-96f7-4fe1a048288f
septlatinxmlcorpus = begin
	reloadtext
	readcitable(septlatinxml, CtsUrn("urn:cts:compnov:bible.genesis.sept_latin:"), TEIDivAb, FileReader)
end

# ╔═╡ 9af25ad8-168c-4f28-9d24-54164b298db7
septlatin = edited(bldr, septlatinxmlcorpus)

# ╔═╡ 96ea76d5-0e3d-46df-b807-97a9a61ac519
septlatintkns = tokenize(septlatin, vulgateortho)

# ╔═╡ 4676bd78-0a1c-48ec-9a38-6171fc168b96
septlatinpsg =  filter(septlatintkns) do tkn
	passagebase = verse * "."
	workid(tkn.passage.urn) == book &&
	startswith(passagecomponent(tkn.passage.urn), passagebase)
end

# ╔═╡ 298c9a4b-2a24-4c7d-8575-e0f42ae16044
septlatindiff = formatdiff( septlatinpsg, vulgatepsg) 

# ╔═╡ 44522bfa-9420-4aac-a402-5f55ebc29e05
vulgatediff = formatdiff(vulgatepsg, septlatinpsg) 

# ╔═╡ 7d789a64-08f5-492f-9d02-e1ed674570ca
targumlatinxml =  joinpath(repo, "editions", "targum_latin_genesis.xml")

# ╔═╡ 8f070001-b104-4d5d-9b08-90a1e0247892
targumlatinxmlcorpus = begin
	reloadtext
	readcitable(targumlatinxml, CtsUrn("urn:cts:compnov:bible.genesis.sept_latin:"), TEIDivAb, FileReader)
end

# ╔═╡ 2a6dc443-9ccc-4c74-95e0-a6a7c126cea6
targumlatin = edited(bldr, targumlatinxmlcorpus)

# ╔═╡ 048b9dc6-7e1d-4180-bb00-7efca50656ce
targumlatintkns = tokenize(targumlatin, vulgateortho)

# ╔═╡ fb2be480-9679-4a69-a578-091ae1c6f7b2

targumlatinpsg = filter(targumlatintkns) do tkn
	passagebase = verse * "."
	workid(tkn.passage.urn) == book &&
	startswith(passagecomponent(tkn.passage.urn), passagebase)
end

# ╔═╡ 5af37c2d-595d-4043-a601-22f88e55ef79
targumlatindiff = formatdiff( targumlatinpsg, vulgatepsg) 

# ╔═╡ 966eedc9-1c4d-4117-8076-26b8eda54e96
"""
<table>
<tr><th><i>Version</i></th><th><i>Text</i></th></tr>
<tr>
<th>Vulgate</th><td>$(vulgatediff)</td>
</tr>
<tr>
<th>Glosses on Septuagint</th><td>$(septlatindiff)</td>
</tr>
<tr>
<th>Septuagint</th><td>$(septuagintpsg[1].text)</td>
</tr>

<tr>
<th>Glosses on Targum Onkelos</th><td>$(targumlatindiff)</td>
</tr>
<tr>

<tr>
<th>Targum Onkelos</th><td>$(targumpsg[1].text)</td>
</tr>
</table>
"""  |> HTML

# ╔═╡ ffc7785d-1750-431d-877a-70c478d6fbc5
md"> ## CSS + HTML"

# ╔═╡ 95d5cb19-ce6b-4e06-8cc6-451faa5ec194
ortho = latin24()

# ╔═╡ acd6ae5a-0390-48e6-bf80-eae7ab9b2910
css = html"""
<style>
.hilite {
	background-color: yellow;
	font-weight: bold;
}
</style>
"""

# ╔═╡ e0a33f4a-3dfb-476c-ac98-7e4934b07b4b
md"""More CSS in next cell, too..."""

# ╔═╡ 5d114d2c-8be4-4d9a-a3a9-dca01082f0bc
@htl """
<style>
	pluto-output {
		--julia-mono-font-stack: system-ui,sans-serif;
	}
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CitableBase = "d6f014bd-995c-41bd-9893-703339864534"
CitableCorpus = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
CitableTeiReaders = "b4325aa9-906c-402e-9c3f-19ab8a88308e"
CitableText = "41e66566-473b-49d4-85b7-da83b66615d8"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
EditionBuilders = "2fb66cca-c1f8-4a32-85dd-1a01a9e8cd8f"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LatinOrthography = "1e3032c9-fa1e-4efb-a2df-a06f238f6146"
Orthography = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CitableBase = "~10.3.1"
CitableCorpus = "~0.13.5"
CitableTeiReaders = "~0.10.3"
CitableText = "~0.16.2"
EditionBuilders = "~0.8.4"
HypertextLiteral = "~0.9.5"
LatinOrthography = "~0.7.2"
Orthography = "~0.21.3"
PlutoUI = "~0.7.55"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.6"
manifest_format = "2.0"
project_hash = "6b5d1971d0d28d87740ca71314899ac755cee3bc"

[[deps.ANSIColoredPrinters]]
git-tree-sha1 = "574baf8110975760d391c710b6341da1afa48d8c"
uuid = "a4c015fc-c6ff-483c-b24f-f7ea428134e9"
version = "0.0.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "c278dfab760520b8bb7e9511b968bf4ba38b7acc"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.3"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "0fb305e0253fd4e833d486914367a2ee2c2e78d0"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.0.1"

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
git-tree-sha1 = "679e69c611fff422038e9e21e270c4197d49d918"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.12"

[[deps.CitableBase]]
deps = ["DocStringExtensions", "Documenter", "Test", "TestSetExtensions"]
git-tree-sha1 = "cc4f1e1db392c4a05eb29026774d6f26ae8ca457"
uuid = "d6f014bd-995c-41bd-9893-703339864534"
version = "10.3.1"

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
git-tree-sha1 = "75bd5b6fc5089df449b5d35fa501c846c9b6549b"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.12.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "8cfa272e8bdedfa88b6aefbbca7c19f1befac519"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.3.0"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "ac67408d9ddf207de5cfa9a97e114352430f01ed"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.16"

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
git-tree-sha1 = "8b73c5a704d74e78a114b785d648ceba1e5790a9"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.4.0"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Documenter]]
deps = ["ANSIColoredPrinters", "AbstractTrees", "Base64", "Dates", "DocStringExtensions", "Downloads", "Git", "IOCapture", "InteractiveUtils", "JSON", "LibGit2", "Logging", "Markdown", "MarkdownAST", "Pkg", "PrecompileTools", "REPL", "RegistryInstances", "SHA", "Test", "Unicode"]
git-tree-sha1 = "2613dbec8f4748273bbe30ba71fd5cb369966bac"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "1.2.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EditionBuilders]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "DocStringExtensions", "Documenter", "EzXML", "Test"]
git-tree-sha1 = "1aae9a01bb737937c3b774c6c7939f9176255ba1"
uuid = "2fb66cca-c1f8-4a32-85dd-1a01a9e8cd8f"
version = "0.8.4"

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
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Git]]
deps = ["Git_jll"]
git-tree-sha1 = "51764e6c2e84c37055e846c516e9015b4a291c7d"
uuid = "d7ba0133-e1db-5d97-8f8c-041e4b3a1eb2"
version = "1.3.0"

[[deps.Git_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "LibCURL_jll", "Libdl", "Libiconv_jll", "OpenSSL_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "b30c473c97fcc1e1e44fab8f3e88fd1b89c9e9d1"
uuid = "f8c6e375-362e-5223-8a59-34ff63f689eb"
version = "2.43.0+0"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "abbbb9ec3afd783a7cbd82ef01dcd088ea051398"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.1"

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

[[deps.LatinOrthography]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "DocStringExtensions", "Documenter", "Orthography", "Test"]
git-tree-sha1 = "2fea442e6ce1e5934b1098c9c849674305c5d2c8"
uuid = "1e3032c9-fa1e-4efb-a2df-a06f238f6146"
version = "0.7.2"

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
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

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
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "60e3045590bd104a16fefb12836c00c0ef8c7f8c"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.13+0"

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
git-tree-sha1 = "68723afdb616445c6caaef6255067a8339f91325"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.55"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

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
git-tree-sha1 = "1d77abd07f617c4868c33d4f5b9e1dbb2643c9cf"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.2"

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

[[deps.TestSetExtensions]]
deps = ["DeepDiffs", "Distributed", "Test"]
git-tree-sha1 = "3a2919a78b04c29a1a57b05e1618e473162b15d0"
uuid = "98d24dd4-01ad-11ea-1b02-c9a08f80db04"
version = "2.0.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "54194d92959d8ebaa8e26227dbe3cdefcdcd594f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.3"
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
git-tree-sha1 = "801cbe47eae69adc50f36c3caec4758d2650741b"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.12.2+0"

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
# ╟─505e5234-c399-11ee-2a14-bfee14a8bf57
# ╟─01cd9b04-4308-4776-ad22-bcd4eb48a966
# ╟─e38b36cc-af33-43df-804d-f65017a84888
# ╟─3c108481-0a07-4849-a973-5384d7a4bfcb
# ╟─36dd1391-3550-4c87-8ba8-4325e007316a
# ╟─f56c3f61-cae0-4d1a-b755-86ddff6d3c53
# ╟─a2171ec8-6691-4f52-b9ec-a6281594d4b2
# ╟─ecbcee9e-9719-4883-8615-20a1602014a6
# ╟─7d035d8d-7f3c-4b1d-9eb9-2069f317109e
# ╟─966eedc9-1c4d-4117-8076-26b8eda54e96
# ╟─571bfd40-3fc5-40ed-beb1-7035e25cf5bc
# ╟─77bbc155-3d5d-4941-9188-d664e45e2d81
# ╟─9aca0d5f-f4ed-44a6-8470-1d0e91b006eb
# ╟─b873d268-5af3-4d6c-a1b7-3af6f3c764bf
# ╟─2a25ecca-558a-46eb-b6a9-7c2ec76a066f
# ╟─cf9ebba5-d90c-42ae-8a11-bdef4660991c
# ╟─80e36d02-a7a0-4b18-9cf7-b26bbcadc345
# ╟─9f98852b-acf8-4740-92c5-00e291d2943c
# ╟─048b9dc6-7e1d-4180-bb00-7efca50656ce
# ╟─96ea76d5-0e3d-46df-b807-97a9a61ac519
# ╟─298c9a4b-2a24-4c7d-8575-e0f42ae16044
# ╟─5af37c2d-595d-4043-a601-22f88e55ef79
# ╟─44522bfa-9420-4aac-a402-5f55ebc29e05
# ╟─1d7b8019-0a2f-42ab-a2f4-ff53d266e1ae
# ╟─ba2247ab-6b07-4230-9661-5cc9a17bed66
# ╟─5cf92532-b67a-40a3-ad1a-c7f03cdb0eda
# ╟─cb77fe26-a3c9-48f9-8364-c6288ffd50d5
# ╟─1c27264c-cb66-4f0f-89ad-8d151a60bd58
# ╟─b049d8ff-6092-4174-9bc8-3138bd272eaf
# ╟─a538cd79-f58f-44d0-b4b3-413461084ff9
# ╟─43f6d597-11ee-4faf-8710-964ca97b2c89
# ╟─ed6016b0-ebba-4403-b6e7-697e8a36e719
# ╠═bb72f016-3098-4814-a2ff-1705bf938a6f
# ╟─0681c83f-f445-460e-891c-2d55ff54d918
# ╟─c1791f30-a4ef-409c-86ce-80708df51291
# ╟─73919628-120d-4317-ba7b-26e74d2d75d9
# ╟─c2379250-5def-4e3e-b310-739c7e1b1587
# ╟─4676bd78-0a1c-48ec-9a38-6171fc168b96
# ╟─22e0f5ff-d3c7-4450-a968-1165aefc1caa
# ╟─09556565-5d85-4684-a476-640aa025bf70
# ╟─fb2be480-9679-4a69-a578-091ae1c6f7b2
# ╟─e2fa65bd-9084-4ce9-805e-9b1565bb5794
# ╟─c2fbb1d6-a63f-47ef-9f5d-fc98fb4f5f5a
# ╟─1eabb81f-291a-4701-ab71-5eaaa8f03693
# ╟─7f933451-896a-48a9-96f7-4fe1a048288f
# ╟─9af25ad8-168c-4f28-9d24-54164b298db7
# ╠═a9592b4a-3db9-485e-a087-32786d584b1f
# ╟─8f070001-b104-4d5d-9b08-90a1e0247892
# ╟─2a6dc443-9ccc-4c74-95e0-a6a7c126cea6
# ╟─50966a9c-b83a-42c2-94b2-a1899fe51f12
# ╟─13825cdf-a2da-4be9-8052-80a86adf024c
# ╟─049e6845-f4e8-4223-a69d-8fbb877e98de
# ╟─7d789a64-08f5-492f-9d02-e1ed674570ca
# ╟─ffc7785d-1750-431d-877a-70c478d6fbc5
# ╟─95d5cb19-ce6b-4e06-8cc6-451faa5ec194
# ╟─acd6ae5a-0390-48e6-bf80-eae7ab9b2910
# ╟─e0a33f4a-3dfb-476c-ac98-7e4934b07b4b
# ╟─5d114d2c-8be4-4d9a-a3a9-dca01082f0bc
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
