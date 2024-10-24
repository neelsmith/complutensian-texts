### A Pluto.jl notebook ###
# v0.19.46

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

# ╔═╡ 8cc6d48d-9e7e-4a9a-9e0e-4d102ec8b225
begin
	using CitableBase, CitableText
	using CitableCorpus
	using StatsBase, OrderedCollections
	using PlutoUI

	using BrownDriverBriggs
	md"""*Unhide this cell to see the Julia environment.*"""
end

# ╔═╡ 77a9a5b0-b486-4bb0-8edc-06f29829b8ce
TableOfContents()

# ╔═╡ cc636d4e-9152-11ef-380b-6f2284ffc745
md"""# Read pre-compiled data on Hebrew verbs"""

# ╔═╡ 9a9763ca-4757-4836-bb91-13e8aa6d1086
md"""## View occurrences and dictionary entry for a selected verb"""

# ╔═╡ 0762a46c-219f-470b-a50f-c6242e8e2be1
md"""

-  *list of verbs is sorted by frequency*
-  *forms derived from the chosen verb are highlighted*

"""

# ╔═╡ e37220c0-019a-4516-bb94-42bf1384daf9
md"""*Show BDB article(s)* $(@bind showbdb CheckBox()) *See passages* $(@bind showpassages CheckBox())"""

# ╔═╡ e9d89a7f-5e3f-4e91-9807-962912253a31
html"""
<br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/>
"""

# ╔═╡ f0e38d33-42b0-411a-a74b-a5b73c8db0a8
md"""> # Mechanics"""

# ╔═╡ cb90bb7c-3ea7-449a-a9e9-3dddec8d92eb
md"""## Text"""

# ╔═╡ 37940b74-9b1b-4d09-b53b-a313d27f0f6b
"""Download Hebrew Bible from `compnov` github repo."""
function gethebrew()
	srcurl = "https://raw.githubusercontent.com/neelsmith/compnov/main/corpus/compnov.cex"
corpus = fromcex(srcurl, CitableTextCorpus, UrlReader)
hebrew = filter(corpus.passages) do psg
	versionid(psg.urn) == "masoretic"
end |> CitableTextCorpus

end

# ╔═╡ 61adccdb-08db-4258-b007-93e3ba743a61
bible = gethebrew()

# ╔═╡ 3f3d3ecb-47cc-4fc8-afbd-7c7ae297b807
md"""## Selected verb"""

# ╔═╡ bb435bca-0868-48fd-9997-fe54a93f25b9
md""" ## Frequencies"""

# ╔═╡ f95ee4a9-2cce-4cc8-b31d-ed1e5e5dca77
md"""## Summaries"""

# ╔═╡ 22a568be-0576-4663-b048-6fef81df547c
md""" ## Source files"""

# ╔═╡ 13d507b9-18ce-4739-a55e-3cf48ec08972
genesisfile = joinpath(dirname(pwd()), "data", "genesis.cex")

# ╔═╡ e5b09a0d-7c16-4b7c-898e-060fe0e66118
exodusfile = joinpath(dirname(pwd()), "data", "exodus.cex")

# ╔═╡ 90a26573-c8a7-462c-affb-2fb0bd4d26a9
leviticusfile = joinpath(dirname(pwd()), "data", "leviticus.cex")

# ╔═╡ 338d61e1-eb43-4d83-addf-4b994dac9b84
numbersfile = joinpath(dirname(pwd()), "data", "numbers.cex")

# ╔═╡ 06db4b52-9469-4e8a-9c3a-5ea694d4dfb5
deuteronomyfile = joinpath(dirname(pwd()), "data", "deuteronomy.cex")

# ╔═╡ c760f46c-aa18-4e71-a5e8-ab3bea88d069
joshuafile = joinpath(dirname(pwd()), "data", "joshua.cex")

# ╔═╡ ae2813d2-f79b-4d12-ba89-03c6c057a590
judgesfile = joinpath(dirname(pwd()), "data", "judges.cex")

# ╔═╡ 70fb2c80-557c-414a-936b-754f53a3b982
ruthfile = joinpath(dirname(pwd()), "data", "ruth.cex")

# ╔═╡ c8abeabc-0259-4090-92ca-447b879e4c8d
samuel1file = joinpath(dirname(pwd()), "data", "1samuel.cex")

# ╔═╡ 91c69e74-fe47-4a05-a05f-bd6c2dd7a7ac
samuel2file = joinpath(dirname(pwd()), "data", "2samuel.cex")

# ╔═╡ 3ae1bc48-eb91-4c73-bc5f-7ea109a2c462
kings1file = joinpath(dirname(pwd()), "data", "1kings.cex")

# ╔═╡ 9dbf8ebe-abd3-45dd-8a48-6125c7bc7a3a
filemenu = [
	genesisfile => "Genesis",
	exodusfile => "Exodus",
	leviticusfile => "Leviticus",
	numbersfile => "Numbers",
	deuteronomyfile => "Deuteronomy",
	"" => "---",
	joshuafile => "Joshua",
	judgesfile => "Judges",
	ruthfile => "Ruth",
	samuel1file => "1 Samuel",
	samuel2file => "2 Samuel",
	kings1file => "1 Kings",
]

# ╔═╡ e4f04e9e-dfa4-4da6-8fb6-e2afc745989a
md"""*Choose a book to examine*: $(@bind srcfile Select(filemenu))"""

# ╔═╡ c56ba726-6941-4d90-9eb6-5c5feb7da64f
kings2file = joinpath(dirname(pwd()), "data", "2kings.cex")

# ╔═╡ e15bd91a-c45d-4771-82b8-bcdcd57fcc20
chronicles2file = joinpath(dirname(pwd()), "data", "2chronicles.cex")

# ╔═╡ e45cd1bc-49e7-4291-be46-991cf32f110c
ezra2file = joinpath(dirname(pwd()), "data", "ezra.cex")

# ╔═╡ f9fc625b-7c52-43f4-8d96-cc38c34b83de
nehemiahfile = joinpath(dirname(pwd()), "data", "nehemiah.cex")

# ╔═╡ 058c0047-a3f4-45f2-afdc-2af3839bf4cb
estherfile = joinpath(dirname(pwd()), "data", "esther.cex")

# ╔═╡ e4eee511-5da9-45dd-9919-995550305ca1
psalmsfile = joinpath(dirname(pwd()), "data", "psalms.cex")

# ╔═╡ 1be84181-1999-40ca-8ed9-30d950ba8ca8
proverbsfile = joinpath(dirname(pwd()), "data", "proverbs.cex")

# ╔═╡ a57a3138-5e69-495d-ae82-59a733b8dd9c
ecclesiastesfile = joinpath(dirname(pwd()), "data", "ecclesiastes.cex")

# ╔═╡ 5f468021-eb9b-47f6-8a5e-eb56a97e0721
songsfile = joinpath(dirname(pwd()), "data", "songs.cex")

# ╔═╡ aac41c94-b7f8-4e2f-ad1b-7bf1f9dd7219
isaiahfile = joinpath(dirname(pwd()), "data", "isaiah.cex")

# ╔═╡ db346f4f-f67d-43b9-a8b0-7b86f8b08237
jeremiahfile = joinpath(dirname(pwd()), "data", "jeremiah.cex")

# ╔═╡ f51331e5-17a4-4e2a-bc31-1f60a406d265
danielfile = joinpath(dirname(pwd()), "data", "daniel.cex")

# ╔═╡ 2ac07776-7472-49f2-b665-170d5744ef77
hoseafile = joinpath(dirname(pwd()), "data", "hosea.cex")

# ╔═╡ c2bd5717-ddc3-4a0e-b84e-365a786de53a
joelfile = joinpath(dirname(pwd()), "data", "joel.cex")

# ╔═╡ 164de5e5-4acd-4afb-921c-1dd50ca7ad08
amosfile = joinpath(dirname(pwd()), "data", "amos.cex")

# ╔═╡ a7565935-466c-480c-9b67-460feb7cfada
obadiahfile = joinpath(dirname(pwd()), "data", "obadiah.cex")

# ╔═╡ e317bd48-dde0-49c1-98c7-f2c684b39802
jonahfile = joinpath(dirname(pwd()), "data", "jonah.cex")

# ╔═╡ 8c69bdb0-4103-4351-be6c-0c52d915becf
micahfile = joinpath(dirname(pwd()), "data", "micah.cex")

# ╔═╡ 6f1f43a6-8763-47eb-8748-c9457b5b152b
nahumfile = joinpath(dirname(pwd()), "data", "nahum.cex")

# ╔═╡ c472f05e-5523-45c3-a76c-aabbc6db3edc
habakkukfile = joinpath(dirname(pwd()), "data", "habakkuk.cex")

# ╔═╡ c3ddf726-02f3-4a68-855b-68cdfdc8170b
zephaniahfile = joinpath(dirname(pwd()), "data", "zephaniah.cex")

# ╔═╡ 99b988bb-5adb-4528-a5d7-a614ab019b21
haggaifile = joinpath(dirname(pwd()), "data", "haggai.cex")

# ╔═╡ 95a6c43d-1e04-4a62-9979-df8f5d36da76
zecariahfile = joinpath(dirname(pwd()), "data", "zecariah.cex")

# ╔═╡ 2311605e-8eb4-4345-89c2-0eadfbef3704
malachifile = joinpath(dirname(pwd()), "data", "malachi.cex")

# ╔═╡ e7d6a7a2-b89d-4323-83d0-2d13023dc7f8
md"""## Read data"""

# ╔═╡ c987da96-66a7-4c59-87fa-e6b20d6ec47f
datalines = isempty(srcfile) ? [] : readlines(srcfile)[2:end]

# ╔═╡ b73b4882-d892-4e5e-965e-cc667b65884e
"""Read data from a file into a vector or named tuples."""
function readdatafile(f)
	# Skip header line:
	raw = readlines(f)[2:end]
	data = map(filter(ln -> ! isempty(ln), raw)) do ln
		(urnstring, form, lemma, bdbid) = split(ln, "|")
		(urn = CtsUrn(urnstring), form = form, lemma = lemma, bdbid = bdbid)
	end
end

# ╔═╡ 9abeb236-35d7-49a4-9a90-a1fdd5b8082a
data = readdatafile(srcfile)

# ╔═╡ 8f8ebe6c-2a64-46d6-9d4e-5661fb87f88c
idcountsraw = map(tup -> tup.bdbid, data) |> countmap |> OrderedDict

# ╔═╡ b58cba31-1067-440e-a632-ef634759d2ce
idcounts = sort(idcountsraw; rev = true, byvalue= true)

# ╔═╡ 5abf0bbf-00cb-4d75-be2c-a3063208ae51
lemmacountsraw = map(tup -> tup.lemma, data) |> countmap |> OrderedDict

# ╔═╡ abfbb01e-b60c-49eb-83ac-d2250a6a7894
lemmacounts = sort(lemmacountsraw; rev = true, byvalue= true)

# ╔═╡ 8fff7dd1-a495-49a7-b5dc-f0c68cf7af36
freqmenu = begin
	lemmafreqs = Pair{String, String}[
		"" => "--choose a verb--"
		
	]
	for k in keys(lemmacounts)
		push!(lemmafreqs, k => string("Verb ", k, " (", lemmacounts[k], " occurrences)"))
	end
	lemmafreqs
end

# ╔═╡ 880cbecc-43b4-458c-9562-40f3f88c9cf1
@bind selectedlemma Select(lemmafreqs)

# ╔═╡ 15be1b5b-76cd-44a1-8bb4-375171e7ec72
verses = map(data) do tup
	collapsePassageBy(tup.urn,1) |> passagecomponent
end |> unique


# ╔═╡ 82723411-e0e1-48b8-988a-078b2b7fca86
chapters = map(data) do tup
		collapsePassageBy(tup.urn,2) |> passagecomponent
end |> unique

# ╔═╡ 3736905f-0dba-4366-ad62-c673bc934fcb
occurrences =  map(data) do tup
		tup.urn |> passagecomponent
end |> unique 


# ╔═╡ 62e1853c-1791-4fff-b4c6-bd236e16d2b8
forms = map(tup -> tup.form, data) |> unique

# ╔═╡ ce454866-645e-43e8-b8a2-44b90bff6f08
ids = map(tup -> tup.bdbid, data) |> unique

# ╔═╡ f4a1fce3-a834-466d-8614-444bf9ccc817
md"""## Summary of selected book

For selected book:

- Identified **$(length(forms))** distinct forms from **$(length(ids))** distinct verbs
- These appear in **$(length(occurrences))** occurrences of verb forms, distributed in  **$(length(verses))** verses of  **$(length(chapters))** chapters



"""

# ╔═╡ e3588b70-8a10-45d8-b41e-f52f0195db82
md"""## HTML + CSS"""

# ╔═╡ 858d613c-59fe-4223-ac21-0ddcddd9ee5c
matchtuples = filter(tup -> tup.lemma == selectedlemma, data)

# ╔═╡ 03faaea2-9ed6-4048-ab23-62c821b7a491
selectedid = isempty(matchtuples) ? nothing : matchtuples[1].bdbid

# ╔═╡ 98b3e315-6238-4ea4-b6ba-b296ec09895b
selectedbdb = isempty(matchtuples) ? nothing : filter(bdb(matchtuples[1].form)) do dictarticle
	id(dictarticle) == selectedid
end

# ╔═╡ 5fddbf3c-58eb-4329-935c-43408c72a05d
"""Format a single tuple for display in HTML."""
function formatmatch(tupl; corp = bible)
	targeturn = collapsePassageBy(tupl.urn, 1)
	occurrence = tupl.form
	
	matchpsgs = filter(p -> passagecomponent(p.urn) == passagecomponent(targeturn) && workid(p.urn) == workid(targeturn), corp.passages)

	htmltext = map(matchpsgs) do psg
		replace(psg.text, occurrence => "<span class=\"hilite\">" * occurrence * "</span>")
	end

	
	"<i>$(titlecase(workid(targeturn)))</i> <b>$(passagecomponent(targeturn))</b>:" * join(htmltext,"\n")
	
end

# ╔═╡ b33139c8-b864-4ae6-8c4b-26edc1816cb2
function bdbhtml()
	join(html_string.(selectedbdb), "\n\n")
end

# ╔═╡ c8c58df0-998d-4625-b25f-3802a2166500
if showbdb
	bdbhtml() |> HTML
end

# ╔═╡ 469497ce-165a-4f52-b682-64eb3900fbd0
function passageshtml()
	paras = map(matchtuples) do tup
		"<li>" * formatmatch(tup) * "</li>"
	end
	htmllist =  isempty(paras) ? "" : "<h3>Results</h3><ol>" * join(paras,"\n") * "</ol>" 
	
	
	htmllist #|> HTML
end

# ╔═╡ bc47a2ac-e987-4b4b-bb06-f1eede1556fc
if showpassages
	passageshtml() |> HTML
end

# ╔═╡ 2013b63e-5933-4444-b1f9-e3166de2bf53
html"""
<style>
	.hilite {
		color: orange;
	}
</style>
"""

# ╔═╡ 11f902c4-e18e-4e76-92cd-1fb73193d2a9
md"""## Debugging"""

# ╔═╡ d51889c3-9f95-419e-b431-40506c916448
map(p -> workid(p.urn), bible.passages) |> unique

# ╔═╡ 20a753fe-a194-46df-9729-fc5a1d06cf1f
allfilenames = filter(fname -> ! isempty(fname), map(pr -> pr[1], filemenu))

# ╔═╡ 9870b618-cf59-4380-a1aa-de67adccf5ac
dataperfile = map(f -> readdatafile(f), allfilenames)

# ╔═╡ 303ffcac-2a6d-4c12-a44a-889ad6bec209
allverbtuples = vcat(dataperfile...)

# ╔═╡ e01a6c6e-02a6-4afd-8eae-0af922056bf2
md"""
## Overall coverage

For entire Hebrew Bible:

- books in selection menu include **$(allverbtuples |> length)** verb records from Sefaria."""

# ╔═╡ f82c92b5-3a24-4832-bd04-09dbb4d6cfc8


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BrownDriverBriggs = "ed877a0f-8e86-4599-984a-df81107104eb"
CitableBase = "d6f014bd-995c-41bd-9893-703339864534"
CitableCorpus = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
CitableText = "41e66566-473b-49d4-85b7-da83b66615d8"
OrderedCollections = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
BrownDriverBriggs = "~0.2.0"
CitableBase = "~10.4.0"
CitableCorpus = "~0.13.5"
CitableText = "~0.16.2"
OrderedCollections = "~1.6.3"
PlutoUI = "~0.7.60"
StatsBase = "~0.34.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.5"
manifest_format = "2.0"
project_hash = "8cbcae07063bf31061f6814fe6ba5400148bc959"

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
git-tree-sha1 = "d80af0733c99ea80575f612813fa6aa71022d33a"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.1.0"

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

[[deps.BiblicalHebrew]]
deps = ["DocStringExtensions", "Documenter", "Orthography", "Test", "TestSetExtensions", "Unicode"]
git-tree-sha1 = "b01c791cd47c33fb5e4ef8311ca6eb814f727759"
uuid = "23d2231d-1fc1-47c2-a612-987552d9b38e"
version = "0.4.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.BrownDriverBriggs]]
deps = ["BiblicalHebrew", "DocStringExtensions", "Documenter", "Downloads", "JSON3", "Orthography", "Test", "TestSetExtensions"]
git-tree-sha1 = "8510a757ec58b1786d7bca5af28c5780ea2ce096"
uuid = "ed877a0f-8e86-4599-984a-df81107104eb"
version = "0.2.0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "deddd8725e5e1cc49ee205a1964256043720a6c3"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.15"

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
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

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
git-tree-sha1 = "5a1ee886566f2fa9318df1273d8b778b9d42712d"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "1.7.0"

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

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "7878ff7172a8e6beedd1dea14bd27c3c6340d361"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.22"
weakdeps = ["Mmap", "Test"]

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

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
git-tree-sha1 = "ea372033d09e4552a04fd38361cd019f9003f4f4"
uuid = "f8c6e375-362e-5223-8a59-34ff63f689eb"
version = "2.46.2+0"

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
git-tree-sha1 = "45521d31238e87ee9f9732561bfee12d4eebd52d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.2"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

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
git-tree-sha1 = "be3dc50a92e5a386872a493a10050136d4703f9b"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "1d322381ef7b087548321d3f878cb4c9bd8f8f9b"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.1"

    [deps.JSON3.extensions]
    JSON3ArrowExt = ["ArrowTypes"]

    [deps.JSON3.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

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
git-tree-sha1 = "7493f61f55a6cce7325f197443aa80d32554ba10"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.15+1"

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
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

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
git-tree-sha1 = "ff11acffdb082493657550959d4feb4b6149e73a"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.5"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

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

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "159331b30e94d7b11379037feeb9b690950cace8"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.11.0"

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
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

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
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

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
# ╟─8cc6d48d-9e7e-4a9a-9e0e-4d102ec8b225
# ╟─77a9a5b0-b486-4bb0-8edc-06f29829b8ce
# ╟─cc636d4e-9152-11ef-380b-6f2284ffc745
# ╟─e01a6c6e-02a6-4afd-8eae-0af922056bf2
# ╟─e4f04e9e-dfa4-4da6-8fb6-e2afc745989a
# ╟─f4a1fce3-a834-466d-8614-444bf9ccc817
# ╟─9a9763ca-4757-4836-bb91-13e8aa6d1086
# ╟─0762a46c-219f-470b-a50f-c6242e8e2be1
# ╟─880cbecc-43b4-458c-9562-40f3f88c9cf1
# ╟─e37220c0-019a-4516-bb94-42bf1384daf9
# ╟─c8c58df0-998d-4625-b25f-3802a2166500
# ╟─bc47a2ac-e987-4b4b-bb06-f1eede1556fc
# ╟─e9d89a7f-5e3f-4e91-9807-962912253a31
# ╟─f0e38d33-42b0-411a-a74b-a5b73c8db0a8
# ╟─cb90bb7c-3ea7-449a-a9e9-3dddec8d92eb
# ╟─37940b74-9b1b-4d09-b53b-a313d27f0f6b
# ╟─61adccdb-08db-4258-b007-93e3ba743a61
# ╟─3f3d3ecb-47cc-4fc8-afbd-7c7ae297b807
# ╟─03faaea2-9ed6-4048-ab23-62c821b7a491
# ╟─98b3e315-6238-4ea4-b6ba-b296ec09895b
# ╟─bb435bca-0868-48fd-9997-fe54a93f25b9
# ╟─8f8ebe6c-2a64-46d6-9d4e-5661fb87f88c
# ╟─b58cba31-1067-440e-a632-ef634759d2ce
# ╟─5abf0bbf-00cb-4d75-be2c-a3063208ae51
# ╟─abfbb01e-b60c-49eb-83ac-d2250a6a7894
# ╟─8fff7dd1-a495-49a7-b5dc-f0c68cf7af36
# ╟─f95ee4a9-2cce-4cc8-b31d-ed1e5e5dca77
# ╟─15be1b5b-76cd-44a1-8bb4-375171e7ec72
# ╟─82723411-e0e1-48b8-988a-078b2b7fca86
# ╟─3736905f-0dba-4366-ad62-c673bc934fcb
# ╟─62e1853c-1791-4fff-b4c6-bd236e16d2b8
# ╟─ce454866-645e-43e8-b8a2-44b90bff6f08
# ╟─22a568be-0576-4663-b048-6fef81df547c
# ╠═9dbf8ebe-abd3-45dd-8a48-6125c7bc7a3a
# ╟─13d507b9-18ce-4739-a55e-3cf48ec08972
# ╟─e5b09a0d-7c16-4b7c-898e-060fe0e66118
# ╟─90a26573-c8a7-462c-affb-2fb0bd4d26a9
# ╟─338d61e1-eb43-4d83-addf-4b994dac9b84
# ╟─06db4b52-9469-4e8a-9c3a-5ea694d4dfb5
# ╟─c760f46c-aa18-4e71-a5e8-ab3bea88d069
# ╟─ae2813d2-f79b-4d12-ba89-03c6c057a590
# ╟─70fb2c80-557c-414a-936b-754f53a3b982
# ╟─c8abeabc-0259-4090-92ca-447b879e4c8d
# ╟─91c69e74-fe47-4a05-a05f-bd6c2dd7a7ac
# ╟─3ae1bc48-eb91-4c73-bc5f-7ea109a2c462
# ╠═c56ba726-6941-4d90-9eb6-5c5feb7da64f
# ╠═e15bd91a-c45d-4771-82b8-bcdcd57fcc20
# ╠═e45cd1bc-49e7-4291-be46-991cf32f110c
# ╠═f9fc625b-7c52-43f4-8d96-cc38c34b83de
# ╠═058c0047-a3f4-45f2-afdc-2af3839bf4cb
# ╠═e4eee511-5da9-45dd-9919-995550305ca1
# ╠═1be84181-1999-40ca-8ed9-30d950ba8ca8
# ╠═a57a3138-5e69-495d-ae82-59a733b8dd9c
# ╠═5f468021-eb9b-47f6-8a5e-eb56a97e0721
# ╠═aac41c94-b7f8-4e2f-ad1b-7bf1f9dd7219
# ╠═db346f4f-f67d-43b9-a8b0-7b86f8b08237
# ╠═f51331e5-17a4-4e2a-bc31-1f60a406d265
# ╠═2ac07776-7472-49f2-b665-170d5744ef77
# ╠═c2bd5717-ddc3-4a0e-b84e-365a786de53a
# ╠═164de5e5-4acd-4afb-921c-1dd50ca7ad08
# ╠═a7565935-466c-480c-9b67-460feb7cfada
# ╠═e317bd48-dde0-49c1-98c7-f2c684b39802
# ╠═8c69bdb0-4103-4351-be6c-0c52d915becf
# ╠═6f1f43a6-8763-47eb-8748-c9457b5b152b
# ╠═c472f05e-5523-45c3-a76c-aabbc6db3edc
# ╠═c3ddf726-02f3-4a68-855b-68cdfdc8170b
# ╠═99b988bb-5adb-4528-a5d7-a614ab019b21
# ╠═95a6c43d-1e04-4a62-9979-df8f5d36da76
# ╠═2311605e-8eb4-4345-89c2-0eadfbef3704
# ╟─e7d6a7a2-b89d-4323-83d0-2d13023dc7f8
# ╟─c987da96-66a7-4c59-87fa-e6b20d6ec47f
# ╟─9abeb236-35d7-49a4-9a90-a1fdd5b8082a
# ╠═b73b4882-d892-4e5e-965e-cc667b65884e
# ╟─e3588b70-8a10-45d8-b41e-f52f0195db82
# ╠═858d613c-59fe-4223-ac21-0ddcddd9ee5c
# ╠═5fddbf3c-58eb-4329-935c-43408c72a05d
# ╠═b33139c8-b864-4ae6-8c4b-26edc1816cb2
# ╠═469497ce-165a-4f52-b682-64eb3900fbd0
# ╠═2013b63e-5933-4444-b1f9-e3166de2bf53
# ╟─11f902c4-e18e-4e76-92cd-1fb73193d2a9
# ╠═d51889c3-9f95-419e-b431-40506c916448
# ╟─20a753fe-a194-46df-9729-fc5a1d06cf1f
# ╟─9870b618-cf59-4380-a1aa-de67adccf5ac
# ╟─303ffcac-2a6d-4c12-a44a-889ad6bec209
# ╠═f82c92b5-3a24-4832-bd04-09dbb4d6cfc8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
