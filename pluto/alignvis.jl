### A Pluto.jl notebook ###
# v0.19.42

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

# ╔═╡ 6cd35fe4-32f3-11ef-23a7-25b03dbd4a6a
# ╠═╡ show_logs = false
begin
	using Pkg
	Pkg.add(url = "https://github.com/neelsmith/Complutensian.jl")
	using Complutensian

	Pkg.add("CitableText")
	using CitableText
	
	using Markdown
	Pkg.add("PlutoUI")
	using PlutoUI

	md"""*To see Julia environment, unhide this cell.*"""
end

# ╔═╡ 34e2e4d6-ba9e-4652-9d1c-be7a80386978
pwd()

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

# ╔═╡ 9988e7cd-7d52-43ea-8bbc-4237a56a002e
verbdataraw = loadverbdata()


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

# ╔═╡ 121f116d-79dd-4b5e-a3c5-debb7187065c
verbdata = filter(v -> (v.lexeme in skips) == false, verbdataraw)

# ╔═╡ 195b55f6-21e5-4a85-a2eb-40e95801dcc5
length(verbdata)

# ╔═╡ 0f533e23-757a-4882-8f8a-2ce16fee2b11
labels = loadlabels()

# ╔═╡ 954fabb3-6c65-464a-9b3c-0f115df029db
"""Compose an HTML table for table of alignments."""
function alignmenttab(vrb, data; lbls = labels)
	psgids = passagesforverb(vrb,data)
	urns = map(psg -> urnforpassage(psg, data), psgids)
	psglabels = map(u -> string("<i>", titlecase(workid(u)), "</i> ", passagecomponent(u)), urns)
	vulgateranks = map(passagesforverb(vrb,data)) do psg
		alignverb(vrb, "vulgate", psg,data)
	end
	targumranks = map(passagesforverb(vrb,data)) do psg
		alignverb(vrb, "targum", psg,data)
	end
	lxxranks = map(passagesforverb(vrb,data)) do psg
		alignverb(vrb, "septuagint", psg,data)
	end

	
	htmlout = ["<table>",
		"<tr><th>Passage</th><th>Vulgate</th><th>Septuagint</th><th>Targum</th></tr>"
	]

	verblabel = labellex(vrb; labelsdict = labels)
	totalpsgs = length(vulgateranks) 
	
	
	summary = totalpsgs == 1 ? "<p><i>$(verblabel)</i> appears in <b>1</b> passage:</p>" : "<p><i>$(verblabel)</i> appears in <b>$(totalpsgs)</b> passages:</p>"
	push!(htmlout, summary)
	
	for i in 1:totalpsgs
		v = ""
		if ! isnothing(vulgateranks[i])
			v = vulgateranks[i].rank == 0 ? "<span class=\"match\">match</span>" : string("<b>",vulgateranks[i].rank,  "</b> ",  labellex(vulgateranks[i].lexeme; labelsdict = lbls))
		end

		s = ""
		if ! isnothing(lxxranks[i])
			s = lxxranks[i].rank == 0 ? "<span class=\"match\">match</span>"  : string("<b>", lxxranks[i].rank,  "</b> ",  labellex(lxxranks[i].lexeme; labelsdict = lbls))
		end

		t = ""
		if ! isnothing(targumranks[i])
			t = targumranks[i].rank == 0 ? "<span class=\"match\">match</span>" : string("<b>", targumranks[i].rank,  "</b> ",  labellex(targumranks[i].lexeme; labelsdict = lbls))
		end
		
		row = "<tr><td>$(psglabels[i])</td><td>$(v)</td><td>$(s)</td><td>$(t)</td></tr>"
		push!(htmlout, row)
	end
	push!(htmlout, "</table>")
	join(htmlout) |> HTML
end

# ╔═╡ e8cffc02-fe2b-40bc-a446-38eda5a79657
 allverbs = verblist(verbdata)

# ╔═╡ e29fa791-8f01-43e8-8d2c-5673f7abe4fb
verbsmenu =  map(allverbs) do v
	Pair(v, labellex(v; labelsdict = labels))
end

# ╔═╡ b2d023e3-a79a-4830-b276-b54525e8c0b7
md"""*Choose a verb*: $(@bind verbchoice Select(verbsmenu))"""

# ╔═╡ 08c0ab69-4b06-4243-ba87-b0d880e490cb
md"""## Alignments with *$(labellex(verbchoice; labelsdict = labels))*"""

# ╔═╡ f61455da-0d8f-48b6-b5ab-9e14186281cf
alignmenttab(verbchoice, verbdata)

# ╔═╡ a09b12f6-1957-414b-b542-e6df7782ded3
length(allverbs)

# ╔═╡ 07969ca0-7ec5-43d8-99b9-4d86dceb396c
eo in allverbs

# ╔═╡ Cell order:
# ╠═34e2e4d6-ba9e-4652-9d1c-be7a80386978
# ╟─6cd35fe4-32f3-11ef-23a7-25b03dbd4a6a
# ╟─b2d023e3-a79a-4830-b276-b54525e8c0b7
# ╟─08c0ab69-4b06-4243-ba87-b0d880e490cb
# ╟─f61455da-0d8f-48b6-b5ab-9e14186281cf
# ╟─d81c5cfd-8ebb-492d-a45c-44163e333379
# ╟─e5ec8309-58cc-4127-998d-da4ff70ac34c
# ╠═e29fa791-8f01-43e8-8d2c-5673f7abe4fb
# ╟─954fabb3-6c65-464a-9b3c-0f115df029db
# ╠═6662a744-a6ab-4609-b4dd-05cc0cb5e78b
# ╟─b7cb6ead-9d89-4532-a5e5-bddaecef8338
# ╟─9988e7cd-7d52-43ea-8bbc-4237a56a002e
# ╟─d26fff15-871c-424b-bc68-3df2cf48752a
# ╟─ce2f65bc-8e6b-4f2f-ba3e-2ec3c0d07f0e
# ╟─2d6fdab9-0abd-4f21-aa5d-2a6c9eafbc9c
# ╠═a3263b9e-a1bd-462b-9b83-71a839b4d040
# ╠═8d4e5b24-6024-4fa5-81e2-91376f754fd1
# ╠═a45d2229-e648-443a-b87f-7974782027e1
# ╠═50b2ada9-5bae-4fb7-993f-3228d27f5ccb
# ╠═195b55f6-21e5-4a85-a2eb-40e95801dcc5
# ╠═a09b12f6-1957-414b-b542-e6df7782ded3
# ╟─121f116d-79dd-4b5e-a3c5-debb7187065c
# ╟─0f533e23-757a-4882-8f8a-2ce16fee2b11
# ╟─e8cffc02-fe2b-40bc-a446-38eda5a79657
# ╠═07969ca0-7ec5-43d8-99b9-4d86dceb396c
