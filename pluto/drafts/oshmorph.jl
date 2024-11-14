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

# ╔═╡ e413ead8-5f8b-4823-b06d-3ce7c9c54e3e
# ╠═╡ show_logs = false
begin
    import Pkg
    # activate a temporary environment
    Pkg.activate(mktempdir())
    # Pkg.add([
    #    Pkg.PackageSpec(name="Plots", version="1"),
    #    Pkg.PackageSpec(name="PlutoUI", version="0.7"),
    #])
	Pkg.add("CitableBase")
	Pkg.add("CitableText")
	Pkg.add("CitableCorpus")

	Pkg.add(url = "https://github.com/neelsmith/OpenScripturesHebrew.jl.git")
    
	Pkg.add("PlutoUI")
	using CitableBase, CitableText, CitableCorpus
	using OpenScripturesHebrew
	using PlutoUI
	md"""*Unhide this cell to see the Julia environment.*"""
end

# ╔═╡ 442035cb-b1f2-4a94-8aa7-c92d213dea8f
TableOfContents()

# ╔═╡ 4318493c-0535-4b9f-ae9b-940b7f053985
md"""# Unifying OSH morphology and citable corpora"""

# ╔═╡ 90e102cc-7084-4789-8854-265799b564b7
html"""
<br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
"""

# ╔═╡ d4e9d6d1-6ce7-4b58-b194-e3e13467b162
md"""
---

> # Mechanics
"""

# ╔═╡ 19dc0b26-d9b0-40d8-8034-d88970ac2eaa
md"""## Text corpus"""

# ╔═╡ 8b746d9e-9dc9-11ef-1fd0-fb2ebc19f1e5
compnovurl = "https://github.com/neelsmith/compnov/raw/main/corpus/compnov.cex"

# ╔═╡ e91ae5d5-d61e-452e-b04e-28afc16d6c6b
corpus = fromcex(compnovurl, CitableTextCorpus, UrlReader)

# ╔═╡ fcabcbe2-fdb9-4263-991b-ab9accd206dd
vulgate = filter(psg -> versionid(psg.urn) == "vulgate", corpus.passages)

# ╔═╡ 956a4e58-87f2-4ee5-bcc6-7ecb447798bc
booklist = map(psg -> workid(psg.urn), vulgate) |> unique

# ╔═╡ 98bd2f50-1e79-4458-9903-1fa078afe748
md""" ## OSH morphology"""

# ╔═╡ 04fd5f4c-d4ee-40ef-ac95-f42b0d7e1ccc
"Download OSH morphology for the entire Hebrew Bible."
function getosh()
	bookwords = []
	for bk in keys(OpenScripturesHebrew.bookids)
    	push!(bookwords, compilewords_remote(bk))
	end
	bookwords |> Iterators.flatten |> collect
end

# ╔═╡ 86a1bcf7-6fcd-40f7-bb84-7b73545e586d
# ╠═╡ show_logs = false
words = getosh()

# ╔═╡ a15eba17-6cf2-493b-91e7-e05edf6ded20
md"""## Mapping OSH to URNs"""

# ╔═╡ b97bc82e-1020-4eb8-b2cf-41b0c1f87b5d
"Create a new Dict flipping the relation of key-value."
function reverse_dict(d)
	newdict = Dict()
	for k in keys(d)
		newdict[d[k]] = k
	end
	newdict	
end

# ╔═╡ ba566bdb-2fc6-440f-9705-4c94a3df564a
oshkeys = reverse_dict(OpenScripturesHebrew.bookids)

# ╔═╡ 96ac621a-a27d-4e7a-b395-f914d55a6d41
"Make a menu to get OSH book names from a display of URN IDs"
function bookmenu()
	menu = Pair{String,String}[]
	for bk in booklist
		if bk in keys(oshkeys)
			push!(menu, oshkeys[bk] => bk)
		end
		
	end
	menu
end

# ╔═╡ 390c107c-d607-4717-8617-6ab8795b9b6e
@bind book Select(bookmenu())

# ╔═╡ cf133935-5685-40a6-a2fd-8ddf59b5ff82
bookwords = compilewords_remote(book)

# ╔═╡ Cell order:
# ╟─442035cb-b1f2-4a94-8aa7-c92d213dea8f
# ╟─e413ead8-5f8b-4823-b06d-3ce7c9c54e3e
# ╟─4318493c-0535-4b9f-ae9b-940b7f053985
# ╟─390c107c-d607-4717-8617-6ab8795b9b6e
# ╟─cf133935-5685-40a6-a2fd-8ddf59b5ff82
# ╟─90e102cc-7084-4789-8854-265799b564b7
# ╟─d4e9d6d1-6ce7-4b58-b194-e3e13467b162
# ╟─19dc0b26-d9b0-40d8-8034-d88970ac2eaa
# ╟─8b746d9e-9dc9-11ef-1fd0-fb2ebc19f1e5
# ╟─e91ae5d5-d61e-452e-b04e-28afc16d6c6b
# ╟─fcabcbe2-fdb9-4263-991b-ab9accd206dd
# ╟─956a4e58-87f2-4ee5-bcc6-7ecb447798bc
# ╟─98bd2f50-1e79-4458-9903-1fa078afe748
# ╟─04fd5f4c-d4ee-40ef-ac95-f42b0d7e1ccc
# ╟─86a1bcf7-6fcd-40f7-bb84-7b73545e586d
# ╟─a15eba17-6cf2-493b-91e7-e05edf6ded20
# ╟─b97bc82e-1020-4eb8-b2cf-41b0c1f87b5d
# ╟─ba566bdb-2fc6-440f-9705-4c94a3df564a
# ╟─96ac621a-a27d-4e7a-b395-f914d55a6d41
