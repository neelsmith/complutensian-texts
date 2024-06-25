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
verbdata = loadverbdata()


# ╔═╡ 0f533e23-757a-4882-8f8a-2ce16fee2b11
labels = loadlabels()

# ╔═╡ 954fabb3-6c65-464a-9b3c-0f115df029db
function alignmenttab(vrb, data; lbls = labels)
	psgids = passagesforverb(vrb,data)
	urns = map(psg -> urnforpsg(psg, data), psgids)
	psglabels = map(u -> string("<i>", titlecase(workid(u)), "</i> ", passagecomponent(u)), urns)
	vulgateranks = map(passagesforverb(vrb,verbdata)) do psg
		alignverb(vrb, "vulgate", psg,verbdata)
	end
	targumranks = map(passagesforverb(vrb,verbdata)) do psg
		alignverb(vrb, "targum", psg,verbdata)
	end
	lxxranks = map(passagesforverb(vrb,verbdata)) do psg
		alignverb(vrb, "septuagint", psg,verbdata)
	end

	
	htmlout = ["<table>",
		"<tr><th>Passage</th><th>Vulgate</th><th>Septuagint</th><th>Targum</th></tr>"
	]
	for i in 1:length(vulgateranks)

		v = vulgateranks[i].rank == 0 ? "<span class=\"match\">match</span>" : string("<b>",vulgateranks[i].rank,  "</b> ",  labellex(vulgateranks[i].lexeme; labelsdict = lbls))

		s = lxxranks[i].rank == 0 ? "<span class=\"match\">match</span>"  : string("<b>", lxxranks[i].rank,  "</b> ",  labellex(lxxranks[i].lexeme; labelsdict = lbls))

		t = targumranks[i].rank == 0 ? "<span class=\"match\">match</span>" : string("<b>", targumranks[i].rank,  "</b> ",  labellex(targumranks[i].lexeme; labelsdict = lbls))
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

# ╔═╡ 785f9c3d-3fee-4e8d-b596-56a2bae687d8


# ╔═╡ Cell order:
# ╟─6cd35fe4-32f3-11ef-23a7-25b03dbd4a6a
# ╟─b2d023e3-a79a-4830-b276-b54525e8c0b7
# ╟─08c0ab69-4b06-4243-ba87-b0d880e490cb
# ╟─f61455da-0d8f-48b6-b5ab-9e14186281cf
# ╟─d81c5cfd-8ebb-492d-a45c-44163e333379
# ╟─e5ec8309-58cc-4127-998d-da4ff70ac34c
# ╠═e29fa791-8f01-43e8-8d2c-5673f7abe4fb
# ╠═954fabb3-6c65-464a-9b3c-0f115df029db
# ╠═6662a744-a6ab-4609-b4dd-05cc0cb5e78b
# ╟─b7cb6ead-9d89-4532-a5e5-bddaecef8338
# ╟─9988e7cd-7d52-43ea-8bbc-4237a56a002e
# ╠═0f533e23-757a-4882-8f8a-2ce16fee2b11
# ╠═e8cffc02-fe2b-40bc-a446-38eda5a79657
# ╠═785f9c3d-3fee-4e8d-b596-56a2bae687d8
