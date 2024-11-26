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

# ╔═╡ 4037e0e0-9e55-4bbf-9389-23fd00c540cc
begin
	using PlutoUI
	using Downloads
	using Markdown
	using StatsBase, OrderedCollections
	
	md"""*Unhide this cell to see the Julia environment.*"""
end

# ╔═╡ 19161990-52b4-408b-ad08-2b021d60b76d
TableOfContents()

# ╔═╡ c4cd3eca-a901-11ef-221d-01795b474879
md"""# Hebrew/Greek/Latin verb alignments"""

# ╔═╡ 3f1c3b5b-a6aa-40de-ab85-8eb03f89a020
md"""*Reference language*: $(@bind keylanguage Select(["Hebrew", "Greek", "Latin"], default = "Greek"))"""

# ╔═╡ 59221c31-d369-426b-ae14-d16a127d0696


# ╔═╡ 0888a4d1-71c5-4b6d-a2f1-156ed7fa9684
function screen(prefs, actuals)
	"Look at $(length(actuals)) verbs"
end

# ╔═╡ 20f336dd-9b5f-4db7-92e8-491d6187ffde
testref = "genesis:1.3"


# ╔═╡ 8aa27093-2324-4824-944f-234ef58a0341
html"""
<br/><br/><br/><br/><br/><br/><br/><br/>
<br/><br/><br/><br/>
"""

# ╔═╡ c52c252b-ed70-44ab-a158-68f11d11a056
md"""---

> # Mechanics
"""

# ╔═╡ d7ca89c2-63cb-4e3b-b536-a4fee1b32b88
md""" ## Text pairings"""

# ╔═╡ aab44b63-6cac-401e-b594-ad952dc6b44c
 t1label = if keylanguage == "Greek" || keylanguage == "Latin"
	"Hebrew"
elseif keylanguage == "Hebrew"
	"Greek"
end

# ╔═╡ 857e0dfc-e92a-400d-a447-f81121e295fa
t1label

# ╔═╡ 4e7f127a-98f9-45eb-ad59-d11f8fb70f62
t1label

# ╔═╡ 18eddf70-a1ab-4377-a178-67748c0f5056
t1label

# ╔═╡ 1369b442-c547-4fe5-81b5-9fd30bae6f68
t2label = if keylanguage == "Greek"
	"Latin"
elseif keylanguage == "Latin"
	"Greek"
elseif keylanguage == "Hebrew"
	"Latin"
end

# ╔═╡ 7f2fe1ee-e261-42f6-9368-a092f7379ccd
md""" ## Verb menus and user selections"""

# ╔═╡ 1285be78-27e0-445e-a325-166a929950df
#chosenpassages[1:passagecount]

# ╔═╡ f31b070f-745b-4b58-8524-e1bea64b0a34
md"""## Verb occurrences"""

# ╔═╡ 9bdfc921-7018-43b1-ae0a-9ffe7a05909d
greekverburl = "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/data/greek/greekverbs.cex"

# ╔═╡ 276c82bb-4872-40cf-9818-65fcdbb8b6d8
latinverburl = "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/data/latin/latinverbs.cex"

# ╔═╡ 345711c4-753d-4831-9e7c-74da06dabf2e
hebrewverburl = "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/data/hebrew/sefariaverbs.cex"

# ╔═╡ 148dce04-3669-46d9-849c-1ddab290b4d7
repo = pwd() |> dirname |> dirname

# ╔═╡ 2a840a00-dd41-4ae1-8568-402ab56b261f
greekverbfile = joinpath(repo, "data", "greek", "greekverbs.cex")

# ╔═╡ 17398e55-86fb-4a9d-8d44-4dfe328d326e
latinverbfile = joinpath(repo, "data", "latin", "latinverbs.cex")

# ╔═╡ 1c378093-ec8c-450b-b2f0-85109a4c011d
hebrewverbfile = joinpath(repo, "data", "hebrew", "sefariaverbs.cex")

# ╔═╡ 00722c18-fa23-49a6-b827-cbcd1cc54c38
"""Read a local file of verb occurrence data into named tuples."""
function getverbslocal(f)
	datalines = filter(l -> ! isempty(l), readlines(f)[2:end])
	tups = map(datalines) do ln
		(ref, lemma, label) = split(ln, "|")
		(ref = ref, lemma = lemma, label = label)
	end
end

# ╔═╡ 7563152c-1b0e-4397-84f1-b2d954c76e5a
"""Download a URL and read a file of verb occurrence data into named tuples."""
function getverbs(url)
	f = Downloads.download(url)
	datalines = filter(l -> ! isempty(l), readlines(f)[2:end])
	rm(f)
	tups = map(datalines) do ln
		(ref, lemma, label) = split(ln, "|")
		(ref = ref, lemma = lemma, label = label)
	end
end

# ╔═╡ baf00831-b64d-4d98-8df6-3e5fa063151b
greekverbconcordance = getverbslocal(greekverbfile)

# ╔═╡ 3f4b7ff2-f34e-4a09-8c7f-4a4f7a0b0fce
greekverbmenu = sort(map(tup -> string(tup.lemma, ":", tup.label), greekverbconcordance) |> countmap |> OrderedDict, rev=true, byvalue = true) |> keys |> collect

# ╔═╡ 886d7bb2-0508-4793-a3eb-a9abdb79a4ef
latinverbconcordance = getverbslocal(latinverbfile)

# ╔═╡ a3753ef9-c3d0-4b0b-90c9-cce0fa119796
latinverbmenu = sort(map(tup -> string(tup.lemma, ":", tup.label), latinverbconcordance) |> countmap |> OrderedDict, rev=true, byvalue = true) |> keys |> collect

# ╔═╡ af905422-41af-4e72-a72d-8a1415eef5aa
hebrewverbconcordance = getverbslocal(hebrewverbfile)

# ╔═╡ ede8bf8e-68b4-4809-9779-4447fa6cd6db
function concordchoice(lang)
	if lang == "Greek" 
		greekverbconcordance
		
		
	elseif lang == "Latin"
		latinverbconcordance
		
	elseif lang == "Hebrew"
		hebrewverbconcordance
			
		
	else
		nothing
	end
	
end

# ╔═╡ a76843d0-2cb6-425c-a1ed-fd4288556a86
psgs1 = filter(concordchoice(t1label)) do tpl
		testref  == tpl.ref
	end

# ╔═╡ 6b499244-78b4-40d4-bc5c-4151674e0b25
conc = if keylanguage == "Latin"
	latinverbconcordance
elseif keylanguage == "Greek"
	greekverbconcordance
elseif keylanguage == "Hebrew"
	hebrewverbconcordance
end

# ╔═╡ 06f74daa-41e8-4fdf-9ca9-6407f676621e
hebrewverbmenu = sort(map(tup -> string(tup.lemma, ":", tup.label), hebrewverbconcordance) |> countmap |> OrderedDict, rev=true, byvalue = true) |> keys |> collect

# ╔═╡ 2a4d843d-c521-4985-b546-d014de5dea58
if keylanguage == "Greek"
	md"""*Choose a verb*: $(@bind verbchoice Select(greekverbmenu))"""
elseif keylanguage == "Latin"
	md"""*Choose a verb*: $(@bind verbchoice Select(latinverbmenu))"""
elseif keylanguage == "Hebrew"
	md"""*Choose a verb*: $(@bind verbchoice Select(hebrewverbmenu))"""
else
	md"Nope"
end

# ╔═╡ 37407be9-a2f2-4895-8975-ca21019ae93d
(chosenlemma, chosenlabel) = split(verbchoice, ":")

# ╔═╡ 1a242b7e-5a54-4a2b-9351-5f12679eb874
md"""## Coccurrences with *$(chosenlabel)* ($(chosenlemma)).
"""

# ╔═╡ 6c043673-6984-4113-aee8-f29272084604
testkey = string(chosenlemma,":",chosenlabel)

# ╔═╡ 77de2a17-4590-4fdf-b2ee-94879c25e720
chosenpassages = filter(tup -> tup.lemma == chosenlemma, conc)

# ╔═╡ 2e440c93-ee80-4c56-954e-b5ebb34bce7b
defaultnum = length(chosenpassages) > 20 ? 20 : legnth(chosenpassages)

# ╔═╡ 3abe6d2c-5d82-42e6-91de-86432ddc18f0
md"""*Number passages to show*: $(@bind passagecount Slider(1:length(chosenpassages), default = defaultnum, show_value= true))"""

# ╔═╡ fa23c556-a740-4538-8093-affc825fb31e
summarymsg = """## **$(length(chosenpassages))** passages for *$(chosenlabel)* (`$(chosenlemma)`)."""


# ╔═╡ 75cfe53a-9966-4c31-811b-a6d9e9906d00
Markdown.parse(summarymsg)

# ╔═╡ cb03d4af-f39f-4a80-ab0c-097ae32ef5e7
md"""## Cooccurrence data"""

# ╔═╡ bdfc3a48-60ce-43d7-bf38-a62f0560da43
h2vurl = "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/data/cooccurrences/hebrew_vulgate.cex"

# ╔═╡ 0ae7a084-8b77-4ddc-8a2a-c92c2c21fea4
h2surl = "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/data/cooccurrences/hebrew_septuagint.cex"

# ╔═╡ ebe0a25c-1973-4640-98e0-207c1d42dfbd
s2vurl = "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/data/cooccurrences/septuagint_vulgate.cex"

# ╔═╡ 04cfe49f-0a32-4813-a8b5-8c262605b503
s2hurl = "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/data/cooccurrences/septuagint_hebrew.cex"

# ╔═╡ ae32e611-4780-4b77-9ca3-6139ef40828b
v2surl = "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/data/cooccurrences/vulgate_septuagint.cex"

# ╔═╡ 164c9759-4dae-4894-991e-5c1f0e533a74
v2hurl = "https://raw.githubusercontent.com/neelsmith/complutensian-texts/refs/heads/main/data/cooccurrences/vulgate_hebrew.cex"

# ╔═╡ e0c675a3-e8e9-4e00-9721-f64d484c1260
h2vfile = joinpath(repo, "data", "cooccurrences", "hebrew_vulgate.cex")

# ╔═╡ 1ad62140-c199-44bb-813d-965bdcc50eb9
h2sfile = joinpath(repo, "data", "cooccurrences", "hebrew_septuagint.cex")

# ╔═╡ 8093125b-f3d2-492a-8996-faf94db3adae
s2hfile = joinpath(repo, "data", "cooccurrences", "septuagint_hebrew.cex")

# ╔═╡ e3b146f7-ca97-4d76-8551-215789ed2cc5
s2vfile = joinpath(repo, "data", "cooccurrences", "septuagint_vulgate.cex")

# ╔═╡ 50b9ed32-a31c-4e3f-b2d9-e74ccea5acc0
v2sfile = joinpath(repo, "data", "cooccurrences", "vulgate_septuagint.cex")

# ╔═╡ 660d8435-a3dd-479e-ab6e-fc0a5a4c3414
v2hfile = joinpath(repo, "data", "cooccurrences", "vulgate_hebrew.cex")

# ╔═╡ 1d49b08a-449c-4f1a-a355-35aa6cc4ffe8
"""Read co-occurrence data from local file into a named tuple."""
function getcooccurslocal(f)
	data = filter(ln -> ! isempty(ln), readlines(f)[2:end])
	map(data) do ln
		(l1, l2, count) = split(ln, "|")
		(lemma1 = l1, lemma2 = l2, count = count)	
	
	end
end

# ╔═╡ df42ca57-1ba1-4c1b-9648-33c3a3410ffc
"""Read co-occurrence data from URL into a named tuple."""
function getcooccurs(url)
	f = Downloads.download(url)
	data = filter(ln -> ! isempty(ln), readlines(f)[2:end])
	rm(f)
	map(data) do ln
		(l1, l2, count) = split(ln, "|")
		(lemma1 = l1, lemma2 = l2, count = count)	
	
	end
end

# ╔═╡ 99692ac2-f31d-490e-8be6-c29858472cc4
md"""Co-occurence dictionaries:"""

# ╔═╡ 2abe8c77-a094-4abf-93f8-d366309a4449
Hebrew2Vulgate = getcooccurslocal(h2vfile)

# ╔═╡ 6dcae0bf-2ffe-42b0-9f85-253f7158c1a2
Hebrew2Septuagint = getcooccurslocal(h2sfile)

# ╔═╡ 12470c5e-7380-4de0-b968-85ca36d7d737
Septuagint2Vulgate = nothing # getcooccurs(s2vurl)

# ╔═╡ c77259b2-c6c8-493c-9230-86f27d0a4011
Septuagint2Hebrew = getcooccurslocal(s2hfile)

# ╔═╡ 7ed35c9d-28b2-4bbc-becd-e9985d6b81e8
Vulgate2Septuagint = getcooccurslocal(v2sfile)

# ╔═╡ 1af7e2b9-7e21-429d-a779-ba43cacc8819
Vulgate2Hebrew = getcooccurslocal(v2hfile)

# ╔═╡ 74105710-3782-48d3-b717-f141aed39be2
"""Chooose cooccurence dictionary for a given pair of languages."""
function cooccurdict(lang1, lang2)
	if lang1 == "Greek" 
		if lang2 == "Latin"
			Septuagint2Vulgate
		elseif lang2 == "Hebrew"
			Septuagint2Hebrew
		end
		
	elseif lang1 == "Latin"
		if lang2 == "Greek"
			Vulgate2Septuagint
		elseif lang2 == "Hebrew"
			Vulgate2Hebrew
		end
		
	elseif lang1 == "Hebrew"
		if lang2 == "Greek"
			Hebrew2Septuagint
		elseif lang2 == "Latin"
			Hebrew2Vulgate
		end
		
	else
		nothing
	end
	
end

# ╔═╡ 2ac7dd9e-804b-4a34-a157-44e6ba10edde
t1dict = cooccurdict(keylanguage, t1label)

# ╔═╡ eb6a3841-1472-45c4-8845-7d5a6fa4760c
t1subdict = filter(t -> t.lemma1 == string(chosenlemma,":", chosenlabel), t1dict)

# ╔═╡ 4b0eef3a-01da-44ae-92bf-8fd54b708653
t1subdictsorted = sort(t1subdict,by =  t -> t.count ) |> reverse

# ╔═╡ 62217f30-d271-4a9f-a9e0-2bab3e4190f5
t1subdictsorted[1:10]

# ╔═╡ 2827f758-2589-4fe9-ad5b-e2544206b391
rows = map(chosenpassages[1:passagecount]) do tup
	dictkey = string(tup.lemma, ":", tup.label)

	
	coocfreqs = filter(t1dict) do coocs
		coocs.lemma1 == dictkey
	end
	psgs1 = filter(concordchoice(t1label)) do tpl
		tup.ref == tpl.ref
	end

	
	
	#psgs2 = filter(concordchoice(t2label)) do tpl
#		tup.ref == tpl.ref
	#end
	
	#$(bestpairing(keylanguage, t2label, chosenlemma, tup.ref))  |"
	
	"| $(tup.ref)  | $(screen(coocfreqs, psgs1)) | 2 | "
end

# ╔═╡ 1fbd8cd2-8803-4f0c-a740-7dbb600fc63d
tbl = "| Passage | Best match: $(t1label) | Best match: $(t2label) |\n| --- |--- | --- |\n" * join(rows,"\n") |> Markdown.parse

# ╔═╡ 27e5493a-204b-4c57-8c1f-a3798dee50c2
t1dict

# ╔═╡ 934a4b25-3f3a-4fcd-b426-6fb572ddd61f
coocfreqs = filter(t1dict) do coocs
		coocs.lemma1 == testkey
	end

# ╔═╡ ecc01ee2-d921-454c-a5b3-6ddd6c3e490e
for p in psgs1
	k = string(p.lemma,":",p.label)
	
	x = filter(coocfreqs) do freq
		freq.lemma2 == k
	end
	#top = x[1]
end

# ╔═╡ c4dc174e-b378-41b7-bb7d-f72c497a89cc
t1dict |> length

# ╔═╡ d716973c-84a2-4e30-952f-d7b2c07d925c
t2dict = cooccurdict(keylanguage, t2label)

# ╔═╡ e8645575-6047-440d-9334-7c566ed6e946
cooccurdict("Greek", "Hebrew")

# ╔═╡ 5560e3ea-f500-4275-becf-44f1dd939711
keylanguage

# ╔═╡ 8474f3c3-c3cb-4520-aa94-dd062fcdf073
t1label

# ╔═╡ 1d713741-179d-4780-a432-981b11b1a48f
function bestpairing(keylang, pairedlang, lemma, ref)
	#dict = cooccurdict(keylang, pairedlang)

	
	"Best match in $(pairedlang) for $(lemma) in $(ref)" # using $(dict)"
	
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
OrderedCollections = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
OrderedCollections = "~1.6.3"
PlutoUI = "~0.7.60"
StatsBase = "~0.34.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.6"
manifest_format = "2.0"
project_hash = "41d49e0b9b02fb2efe2d5dc011ec56f44717692f"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

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

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

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
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

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

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

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

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

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
# ╟─4037e0e0-9e55-4bbf-9389-23fd00c540cc
# ╟─19161990-52b4-408b-ad08-2b021d60b76d
# ╟─c4cd3eca-a901-11ef-221d-01795b474879
# ╟─3f1c3b5b-a6aa-40de-ab85-8eb03f89a020
# ╟─2a4d843d-c521-4985-b546-d014de5dea58
# ╠═62217f30-d271-4a9f-a9e0-2bab3e4190f5
# ╠═59221c31-d369-426b-ae14-d16a127d0696
# ╟─1a242b7e-5a54-4a2b-9351-5f12679eb874
# ╠═4b0eef3a-01da-44ae-92bf-8fd54b708653
# ╠═eb6a3841-1472-45c4-8845-7d5a6fa4760c
# ╟─75cfe53a-9966-4c31-811b-a6d9e9906d00
# ╟─3abe6d2c-5d82-42e6-91de-86432ddc18f0
# ╟─1fbd8cd2-8803-4f0c-a740-7dbb600fc63d
# ╟─2827f758-2589-4fe9-ad5b-e2544206b391
# ╠═0888a4d1-71c5-4b6d-a2f1-156ed7fa9684
# ╠═20f336dd-9b5f-4db7-92e8-491d6187ffde
# ╠═6c043673-6984-4113-aee8-f29272084604
# ╠═27e5493a-204b-4c57-8c1f-a3798dee50c2
# ╠═934a4b25-3f3a-4fcd-b426-6fb572ddd61f
# ╠═a76843d0-2cb6-425c-a1ed-fd4288556a86
# ╠═ecc01ee2-d921-454c-a5b3-6ddd6c3e490e
# ╠═857e0dfc-e92a-400d-a447-f81121e295fa
# ╟─8aa27093-2324-4824-944f-234ef58a0341
# ╟─c52c252b-ed70-44ab-a158-68f11d11a056
# ╟─d7ca89c2-63cb-4e3b-b536-a4fee1b32b88
# ╠═4e7f127a-98f9-45eb-ad59-d11f8fb70f62
# ╠═2ac7dd9e-804b-4a34-a157-44e6ba10edde
# ╠═18eddf70-a1ab-4377-a178-67748c0f5056
# ╠═c4dc174e-b378-41b7-bb7d-f72c497a89cc
# ╠═d716973c-84a2-4e30-952f-d7b2c07d925c
# ╠═ede8bf8e-68b4-4809-9779-4447fa6cd6db
# ╠═e8645575-6047-440d-9334-7c566ed6e946
# ╠═74105710-3782-48d3-b717-f141aed39be2
# ╟─aab44b63-6cac-401e-b594-ad952dc6b44c
# ╟─1369b442-c547-4fe5-81b5-9fd30bae6f68
# ╟─7f2fe1ee-e261-42f6-9368-a092f7379ccd
# ╠═1285be78-27e0-445e-a325-166a929950df
# ╠═2e440c93-ee80-4c56-954e-b5ebb34bce7b
# ╠═37407be9-a2f2-4895-8975-ca21019ae93d
# ╟─6b499244-78b4-40d4-bc5c-4151674e0b25
# ╟─77de2a17-4590-4fdf-b2ee-94879c25e720
# ╠═fa23c556-a740-4538-8093-affc825fb31e
# ╟─3f4b7ff2-f34e-4a09-8c7f-4a4f7a0b0fce
# ╟─a3753ef9-c3d0-4b0b-90c9-cce0fa119796
# ╟─06f74daa-41e8-4fdf-9ca9-6407f676621e
# ╟─f31b070f-745b-4b58-8524-e1bea64b0a34
# ╟─9bdfc921-7018-43b1-ae0a-9ffe7a05909d
# ╟─276c82bb-4872-40cf-9818-65fcdbb8b6d8
# ╟─345711c4-753d-4831-9e7c-74da06dabf2e
# ╠═148dce04-3669-46d9-849c-1ddab290b4d7
# ╠═2a840a00-dd41-4ae1-8568-402ab56b261f
# ╠═17398e55-86fb-4a9d-8d44-4dfe328d326e
# ╠═1c378093-ec8c-450b-b2f0-85109a4c011d
# ╠═00722c18-fa23-49a6-b827-cbcd1cc54c38
# ╠═7563152c-1b0e-4397-84f1-b2d954c76e5a
# ╠═baf00831-b64d-4d98-8df6-3e5fa063151b
# ╠═886d7bb2-0508-4793-a3eb-a9abdb79a4ef
# ╠═af905422-41af-4e72-a72d-8a1415eef5aa
# ╟─cb03d4af-f39f-4a80-ab0c-097ae32ef5e7
# ╠═bdfc3a48-60ce-43d7-bf38-a62f0560da43
# ╠═0ae7a084-8b77-4ddc-8a2a-c92c2c21fea4
# ╟─ebe0a25c-1973-4640-98e0-207c1d42dfbd
# ╠═04cfe49f-0a32-4813-a8b5-8c262605b503
# ╠═ae32e611-4780-4b77-9ca3-6139ef40828b
# ╠═164c9759-4dae-4894-991e-5c1f0e533a74
# ╠═e0c675a3-e8e9-4e00-9721-f64d484c1260
# ╠═1ad62140-c199-44bb-813d-965bdcc50eb9
# ╠═8093125b-f3d2-492a-8996-faf94db3adae
# ╠═e3b146f7-ca97-4d76-8551-215789ed2cc5
# ╠═50b9ed32-a31c-4e3f-b2d9-e74ccea5acc0
# ╠═660d8435-a3dd-479e-ab6e-fc0a5a4c3414
# ╟─1d49b08a-449c-4f1a-a355-35aa6cc4ffe8
# ╟─df42ca57-1ba1-4c1b-9648-33c3a3410ffc
# ╟─99692ac2-f31d-490e-8be6-c29858472cc4
# ╠═2abe8c77-a094-4abf-93f8-d366309a4449
# ╠═6dcae0bf-2ffe-42b0-9f85-253f7158c1a2
# ╟─12470c5e-7380-4de0-b968-85ca36d7d737
# ╠═c77259b2-c6c8-493c-9230-86f27d0a4011
# ╠═7ed35c9d-28b2-4bbc-becd-e9985d6b81e8
# ╠═1af7e2b9-7e21-429d-a779-ba43cacc8819
# ╠═5560e3ea-f500-4275-becf-44f1dd939711
# ╠═8474f3c3-c3cb-4520-aa94-dd062fcdf073
# ╠═1d713741-179d-4780-a432-981b11b1a48f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
