### A Pluto.jl notebook ###
# v0.20.20

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 6cd35fe4-32f3-11ef-23a7-25b03dbd4a6a
# ╠═╡ show_logs = false
begin
	using Pkg
	Pkg.add(url = "https://github.com/neelsmith/Complutensian.jl")
	using Complutensian

	Pkg.add("CitableText")
	using CitableText
	
	using Markdown
	using Downloads
	using Unicode
	
	Pkg.add("PlutoUI")
	using PlutoUI

	Pkg.add("CSV")
	using CSV
	Pkg.add("TypedTables")
	using TypedTables

	md"""*To see Julia environment, unhide this cell.*"""
end

# ╔═╡ 34e2e4d6-ba9e-4652-9d1c-be7a80386978
nbversion = "0.2.0";

# ╔═╡ 6afc33e1-0a59-4162-b2d3-b81e52ba1192
md"""*Notebook version*: **$(nbversion)** *See release notes*: $(@bind releaseinfo CheckBox())"""

# ╔═╡ 223d76fd-5f1d-46f4-954d-c3d2c526d947
if releaseinfo
md"""
- version **0.2.0**: add Greek Septuagint
- version **0.1.0**: initial release
"""
end

# ╔═╡ 175c5696-a2eb-4117-8c8c-d99ade8afe45
TableOfContents()

# ╔═╡ ee7b33a1-e02c-459a-b9f5-3fb8b855bf1d
md"""# Explore automated verb alignments"""

# ╔═╡ b3b22b1a-9a65-47e1-adde-9a12408f1a3b
@bind baselang Select(["Greek", "Latin"])

# ╔═╡ d81c5cfd-8ebb-492d-a45c-44163e333379
html"""
<br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/>
"""

# ╔═╡ e5ec8309-58cc-4127-998d-da4ff70ac34c
md"""> ## HTMLing"""

# ╔═╡ 6662a744-a6ab-4609-b4dd-05cc0cb5e78b
css = html"""
<style>
.match {
	background-color: yellow;
	font-weight: bold;
}
</style>
"""

# ╔═╡ b7cb6ead-9d89-4532-a5e5-bddaecef8338
md"""> ## Data"""

# ╔═╡ d26fff15-871c-424b-bc68-3df2cf48752a
md"""Tweak skip list:"""

# ╔═╡ ce2f65bc-8e6b-4f2f-ba3e-2ec3c0d07f0e
dico = "ls.n13804"

# ╔═╡ 2d6fdab9-0abd-4f21-aa5d-2a6c9eafbc9c
eo = "ls.n15868"

# ╔═╡ a3263b9e-a1bd-462b-9b83-71a839b4d040
facio = "ls.n17516"

# ╔═╡ 8d4e5b24-6024-4fa5-81e2-91376f754fd1
creo = "ls.n11543"

# ╔═╡ a45d2229-e648-443a-b87f-7974782027e1
fero = "ls.n17964"

# ╔═╡ 50b2ada9-5bae-4fb7-993f-3228d27f5ccb
skips = [Complutensian.SUM, dico, eo, facio, fero]

# ╔═╡ c319c43c-ac4f-443c-9640-8018d68072fa
md"""### Labelling"""

# ╔═╡ ba3d4590-d85e-4b88-b03d-4f22837c493c
lsjid_url = "https://raw.githubusercontent.com/neelsmith/Kanones.jl/main/datasets/lsj-vocab/lexemes/lsj.cex"

# ╔═╡ 57499957-c9a6-4150-b9b9-56fe5d44edc7
"""Build a dictionary of lexeme URNs to lemma forms"""
function lsjid_dict(u)
    lsjfile = Downloads.download(u)
    iddict = Dict()
    idpairs = filter(ln -> !isempty(ln), readlines(lsjfile))
    for pr in idpairs[2:end]
        pieces = split(pr, "|")
        x = Unicode.normalize(pieces[2], stripmark = true)
		y = pieces[1]
        iddict[y]= x
    end
	rm(lsjfile)
    iddict
end

# ╔═╡ 380a1611-25aa-473c-b137-e6e90200ee26
lsjlabels = lsjid_dict(lsjid_url)

# ╔═╡ 287532b4-4755-430a-8c4a-22566471ce54
"""Label a Greek lexeme urn with a lemma form"""
function labelgreek(vb; labels = lsjlabels)
	if haskey(labels, vb)
		string(labels[vb], " (", vb, ")")
	else
		vb
	end
end

# ╔═╡ cb71136e-4842-4935-8e6c-172e0574c4d1
repo = pwd() |> dirname |> dirname


# ╔═╡ 3438cd88-5522-449c-89ef-bc3d704c91ba
vlexdata = joinpath(repo, "parses", "verblexemes-current.csv")

# ╔═╡ 5a96e917-2333-4a8b-af2d-55066c260e73
labelsfile = joinpath(repo, "parses", "labels.cex")

# ╔═╡ ca591f71-4c85-4420-9728-9e541853babb
md"""## Local data"""

# ╔═╡ aeea2592-f96a-48a0-bb3d-c460deae332d
"""Get data from local copy of `verblexemes-current.csv`"""
function verbdatalocal(f)
    #url = "http://shot.holycross.edu/complutensian/verblexemes-current.csv"
    dataraw = CSV.File(f) |> Table
	baddata = misaligned(dataraw)
	filter(r -> (r.sequence in baddata) == false, dataraw)
end

# ╔═╡ 9988e7cd-7d52-43ea-8bbc-4237a56a002e
verbdataraw = verbdatalocal(vlexdata) #loadverbdata()


# ╔═╡ 121f116d-79dd-4b5e-a3c5-debb7187065c
verbdata = filter(v -> (v.lexeme in skips) == false, verbdataraw)

# ╔═╡ 195b55f6-21e5-4a85-a2eb-40e95801dcc5
length(verbdata)

# ╔═╡ e8cffc02-fe2b-40bc-a446-38eda5a79657
 allverbs = verblist(verbdata)

# ╔═╡ a09b12f6-1957-414b-b542-e6df7782ded3
length(allverbs)

# ╔═╡ 30e16882-caac-406c-a50e-f05c981f7ead
lsjverbs = filter(v -> startswith(v, "lsj"), allverbs)

# ╔═╡ 35d7f0b6-8648-4a50-b230-1bd7853a9508
greekverbsmenu =  map(lsjverbs) do v
	Pair(v, labelgreek(v))
end

# ╔═╡ 629286fc-323c-4412-83db-0979c503a716
latverbs = filter(v -> ! startswith(v, "lsj"), allverbs)

# ╔═╡ 07969ca0-7ec5-43d8-99b9-4d86dceb396c
eo in allverbs

# ╔═╡ 4be3291e-b133-47aa-8a5e-a7579568b730
verbdatalocal(vlexdata)

# ╔═╡ 8e6a708f-3ac1-4643-8fdf-42f6be4409c1
"""Get labels data from local copy of `labels.cex`"""
function labelslocal(f)
    #lblurl = "http://shot.holycross.edu/complutensian/labels.cex"
	#tmplbls = Downloads.download(lblurl)
	#lns = readlines(tmplbls)
	lns = readlines(f)
	#rm(tmplbls)
	dict = Dict()
	for ln in lns
		parts = split(ln, "|")
		dict[parts[1]] = string(parts[1], " (", parts[2], ")")
	end
	dict
end

# ╔═╡ 0f533e23-757a-4882-8f8a-2ce16fee2b11
labels = labelslocal(labelsfile) # loadlabels()

# ╔═╡ e29fa791-8f01-43e8-8d2c-5673f7abe4fb
verbsmenu =  map(latverbs) do v
	Pair(v, labellex(v; labelsdict = labels))
end

# ╔═╡ b2d023e3-a79a-4830-b276-b54525e8c0b7
if baselang == "Greek"
	md"""*Choose a verb*: $(@bind verbchoice Select(greekverbsmenu))"""
else
	md"""*Choose a verb*: $(@bind verbchoice Select(verbsmenu))"""
end

# ╔═╡ 08c0ab69-4b06-4243-ba87-b0d880e490cb
if baselang == "Greek"
	md"""## Alignments with $(labelgreek(verbchoice; ))"""
else
	md"""## Alignments with *$(labellex(verbchoice; labelsdict = labels))*"""
end

# ╔═╡ 954fabb3-6c65-464a-9b3c-0f115df029db
"""Compose an HTML table for table of alignments."""
function alignmenttab(vrb, data; lbls = labels, lang = baselang)
	psgids = passagesforverb(vrb,data)
	urns = map(psg -> urnforpassage(psg, data), psgids)
	psglabels = map(u -> string("<i>", titlecase(workid(u)), "</i> ", passagecomponent(u)), urns)
	vulgateranks = map(passagesforverb(vrb,data)) do psg
		alignverb(vrb, "vulgate", psg,data)
	end
	targumranks = map(passagesforverb(vrb,data)) do psg
		alignverb(vrb, "targum", psg,data)
	end
	lxxglossranks = map(passagesforverb(vrb,data)) do psg
		alignverb(vrb, "septuagint", psg,data)
	end

	greekranks = map(passagesforverb(vrb,data)) do psg
		alignverb(vrb, "greek", psg,data)
	end

	
	htmlout = ["<table>",
		"<tr><th>Passage</th><th>Vulgate</th><th>LXX glosses</th><th>Septuagint</th><th>Targum glosses</th></tr>"
	]

	verblabel = if lang == "Greek"
		labelgreek(vrb)
	else
		labellex(vrb; labelsdict = labels)
	end
	totalpsgs = length(vulgateranks) 
	

	
	summary = totalpsgs == 1 ? "<p><i>$(verblabel)</i> appears in <b>1</b> passage:</p>" : "<p><i>$(verblabel)</i> appears in <b>$(totalpsgs)</b> passages:</p>"
	push!(htmlout, summary)
	
	for i in 1:totalpsgs
		v = ""
		if ! isnothing(vulgateranks[i])
			v = vulgateranks[i].rank == 0 ? "<span class=\"match\">match</span>" : string("<b>",vulgateranks[i].rank,  "</b> ",  labellex(vulgateranks[i].lexeme; labelsdict = lbls))
		end

		s = ""
		if ! isnothing(lxxglossranks[i])
			s = lxxglossranks[i].rank == 0 ? "<span class=\"match\">match</span>"  : string("<b>", lxxglossranks[i].rank,  "</b> ",  labellex(lxxglossranks[i].lexeme; labelsdict = lbls))
		end

		t = ""
		if ! isnothing(targumranks[i])
			t = targumranks[i].rank == 0 ? "<span class=\"match\">match</span>" : string("<b>", targumranks[i].rank,  "</b> ",  labellex(targumranks[i].lexeme; labelsdict = lbls))
		end


		g = ""
		if ! isnothing(greekranks[i])
			g = greekranks[i].rank == 0 ? "<span class=\"match\">match</span>" : string("<b>", greekranks[i].rank,  "</b> ",  #labellex(greekranks[i].lexeme; labelsdict = lbls))
			labelgreek(greekranks[i].lexeme; labels = lsjlabels))
		end
		row = "<tr><td>$(psglabels[i])</td><td>$(v)</td><td>$(s)</td><td>$(g)</td><td>$(t)</td></tr>"
		push!(htmlout, row)
	end
	push!(htmlout, "</table>")
	join(htmlout) |> HTML
end

# ╔═╡ f61455da-0d8f-48b6-b5ab-9e14186281cf
alignmenttab(verbchoice, verbdata)

# ╔═╡ d958149f-00c3-496b-8695-ded2941e34a7
labelslocal(labelsfile)

# ╔═╡ Cell order:
# ╟─34e2e4d6-ba9e-4652-9d1c-be7a80386978
# ╟─6cd35fe4-32f3-11ef-23a7-25b03dbd4a6a
# ╠═6afc33e1-0a59-4162-b2d3-b81e52ba1192
# ╟─223d76fd-5f1d-46f4-954d-c3d2c526d947
# ╟─175c5696-a2eb-4117-8c8c-d99ade8afe45
# ╟─ee7b33a1-e02c-459a-b9f5-3fb8b855bf1d
# ╟─b3b22b1a-9a65-47e1-adde-9a12408f1a3b
# ╟─b2d023e3-a79a-4830-b276-b54525e8c0b7
# ╟─08c0ab69-4b06-4243-ba87-b0d880e490cb
# ╟─f61455da-0d8f-48b6-b5ab-9e14186281cf
# ╟─d81c5cfd-8ebb-492d-a45c-44163e333379
# ╟─e5ec8309-58cc-4127-998d-da4ff70ac34c
# ╟─e29fa791-8f01-43e8-8d2c-5673f7abe4fb
# ╟─35d7f0b6-8648-4a50-b230-1bd7853a9508
# ╟─954fabb3-6c65-464a-9b3c-0f115df029db
# ╠═6662a744-a6ab-4609-b4dd-05cc0cb5e78b
# ╟─b7cb6ead-9d89-4532-a5e5-bddaecef8338
# ╟─9988e7cd-7d52-43ea-8bbc-4237a56a002e
# ╟─d26fff15-871c-424b-bc68-3df2cf48752a
# ╟─ce2f65bc-8e6b-4f2f-ba3e-2ec3c0d07f0e
# ╟─2d6fdab9-0abd-4f21-aa5d-2a6c9eafbc9c
# ╟─a3263b9e-a1bd-462b-9b83-71a839b4d040
# ╟─8d4e5b24-6024-4fa5-81e2-91376f754fd1
# ╟─a45d2229-e648-443a-b87f-7974782027e1
# ╠═50b2ada9-5bae-4fb7-993f-3228d27f5ccb
# ╠═195b55f6-21e5-4a85-a2eb-40e95801dcc5
# ╠═a09b12f6-1957-414b-b542-e6df7782ded3
# ╟─121f116d-79dd-4b5e-a3c5-debb7187065c
# ╟─0f533e23-757a-4882-8f8a-2ce16fee2b11
# ╟─e8cffc02-fe2b-40bc-a446-38eda5a79657
# ╟─30e16882-caac-406c-a50e-f05c981f7ead
# ╠═629286fc-323c-4412-83db-0979c503a716
# ╠═07969ca0-7ec5-43d8-99b9-4d86dceb396c
# ╟─c319c43c-ac4f-443c-9640-8018d68072fa
# ╟─287532b4-4755-430a-8c4a-22566471ce54
# ╟─380a1611-25aa-473c-b137-e6e90200ee26
# ╟─ba3d4590-d85e-4b88-b03d-4f22837c493c
# ╟─57499957-c9a6-4150-b9b9-56fe5d44edc7
# ╠═cb71136e-4842-4935-8e6c-172e0574c4d1
# ╠═3438cd88-5522-449c-89ef-bc3d704c91ba
# ╠═4be3291e-b133-47aa-8a5e-a7579568b730
# ╠═5a96e917-2333-4a8b-af2d-55066c260e73
# ╠═d958149f-00c3-496b-8695-ded2941e34a7
# ╟─ca591f71-4c85-4420-9728-9e541853babb
# ╟─aeea2592-f96a-48a0-bb3d-c460deae332d
# ╟─8e6a708f-3ac1-4643-8fdf-42f6be4409c1
