### A Pluto.jl notebook ###
# v0.20.0

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

# ╔═╡ 420ba3be-8e4e-11ef-3010-934c9514e951
begin
	using PlutoUI
	using HypertextLiteral	
	md"""*Unhide this cell to see the Julia enviornment.*"""
end

# ╔═╡ d08bd40c-dcd0-4790-a257-33c990e7d74c
nbversion = "1.0.0"

# ╔═╡ e642e877-2467-4405-a72c-117b52f59643
md"""*Notebook version*: **$(nbversion)**. *Show version info*: $(@bind versioninfo CheckBox())"""

# ╔═╡ 80cddf00-adec-42c6-9eab-06d8cb0379a8
if versioninfo
	md"""
- **1.0.0**: initial release	
"""	
end

# ╔═╡ fb037944-4557-4671-9f2a-9db29fabfa1d
md"""
!!! tip "Configuration"
    You need to set your browser to allow cross-origin requests (COR) in order for your notebook to load the IIIF manifests.
"""

# ╔═╡ 83ceda56-aa24-4510-82e7-29ca8ba9c79e
md"""# Complutensian Bible: image browser"""

# ╔═╡ 7eae79ac-5643-46a5-8a9b-2207ef064b64
md"""> *Choose the IIIF manifest for a single volume.*
"""

# ╔═╡ 29e01b88-75ff-43c2-887e-c4182e52a44b
@htl"""
<div id='tify' style='height: 800px'></div>
"""

# ╔═╡ eb508f1b-112a-41b2-8251-0208873e5646
html"""
<br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/>
<br/><br/><br/><br/><br/>
"""

# ╔═╡ 5c1f3cbb-f803-4430-adfc-14c71cb0ec2a
md"""> # Implementation of IIIF client"""

# ╔═╡ 1a2a30a5-c219-4ff0-9b52-923ab2dd19b5
md"""Load TIFY library and accompanying CSS:"""

# ╔═╡ abfa9967-c80b-4e93-b9cd-59e29703a41a
@htl("""
<script src="https://cdn.jsdelivr.net/npm/tify@0.31.0/dist/tify.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/tify@0.31.0/dist/tify.css">
</script>
""")

# ╔═╡ b033d55e-a60d-4877-99d8-41467042de40
md"""Instantiate a TIFY object"""

# ╔═╡ fdaf7392-3ce4-4fbf-a836-a43b8db38230
md"""## Menus of IIIF manifests:"""

# ╔═╡ 4fafa095-ad65-4731-9bab-b7265fb42f0e
shotv1 = "http://shot.holycross.edu/iiif/complutensian/complutensian-bne-v1-manifest.json"

# ╔═╡ e3ce52f3-349e-4fd7-8980-9e57f6d54ba7
shotv2 = "http://shot.holycross.edu/iiif/complutensian/complutensian-bne-v2-manifest.json"

# ╔═╡ 2dbc0d34-7d6f-4f71-b486-f40b8f30ca36
shotv3 = "http://shot.holycross.edu/iiif/complutensian/complutensian-bne-v3-manifest.json"

# ╔═╡ 56a7f320-930f-47d1-a015-2420d23b4b00
shotv4 = "http://shot.holycross.edu/iiif/complutensian/complutensian-bne-v4-manifest.json"

# ╔═╡ a81683d3-9178-4bdb-ac98-a87dfd98e2a4
shotv5 = "http://shot.holycross.edu/iiif/complutensian/complutensian-bne-v5-manifest.json"

# ╔═╡ 3fc0f30c-c710-4af4-887c-0671adbf314a
shotv6 = "http://shot.holycross.edu/iiif/complutensian/complutensian-bne-v6-manifest.json"

# ╔═╡ 31ec531b-4be6-4a50-a70c-d88a586f9cce
localv1 = "http://localhost:8080/iiif/complutensian-bne-v1-manifest.json"

# ╔═╡ ab411ea8-affa-4e86-922e-cb93c5b9e5fd
localv2 = "http://localhost:8080/iiif/complutensian-bne-v2-manifest.json"

# ╔═╡ 02993c0b-4049-4751-bd88-49f3ad575c71
localv3 = "http://localhost:8080/iiif/complutensian-bne-v3-manifest.json"

# ╔═╡ 521d62e3-cd46-4e76-8c57-0d4d53fcf6b0
localv4 = "http://localhost:8080/iiif/complutensian-bne-v4-manifest.json"

# ╔═╡ afafa3b1-63d5-4e3b-a8c7-d04387fddc5a
localv5 = "http://localhost:8080/iiif/complutensian-bne-v5-manifest.json"

# ╔═╡ 8073c51e-75a3-42be-a61a-39b7fd7b3d6b
localv6 = "http://localhost:8080/iiif/complutensian-bne-v6-manifest.json"

# ╔═╡ 9d7397e2-5648-4bd5-a54d-700bc1256d6d
shotmenu = [
	localv1 => "Volume 1 (local server on :8080)",
	localv2 => "Volume 2 (local server on :8080)",
	localv3 => "Volume 3 (local server on :8080)",
	localv4 => "Volume 4 (local server on :8080)",
	localv5 => "Volume 5 (local server on :8080)",
	localv6 => "Volume 6 (local server on :8080)"
]

# ╔═╡ 7c6d8b3d-b31f-46c5-83bc-043c91a70c36
localbne = "http://localhost:8080/iiif/complutensian-bne-manifest.json"

# ╔═╡ bb57547e-ae97-4b8c-879c-1632ce4900ef
md"""## Test data"""

# ╔═╡ 1bb0882b-bf46-4602-b26c-d334b28f97e8
shoturl = "http://shot.holycross.edu/iiif/practice/single-image-iiif.json"

# ╔═╡ 3c449c8e-95ec-4bde-8a50-9e9fc05b5e1b
mwe = "http://localhost:8080/iiif/mwe.json"

# ╔═╡ 3ae6f9d1-e0e3-4046-a5ef-4c69e1af2411
heidelberg = "https://digi.ub.uni-heidelberg.de/diglit/iiif3/cpgraec88/manifest"

# ╔═╡ 74fa184b-b75d-45ce-85a0-572c7d08afcf
localmenu = [
	localv1 => "Volume 1 (local server on :8080)",
	localv2 => "Volume 2 (local server on :8080)",
	localv3 => "Volume 3 (local server on :8080)",
	localv4 => "Volume 4 (local server on :8080)",
	localv5 => "Volume 5 (local server on :8080)",
	localv6 => "Volume 6 (local server on :8080)",
	localbne => "BNE (local server on :8080)",
	mwe => "MWE",
	shoturl => "Served from shoturl.holycross.edu",
	heidelberg => "CP Graec 88 (Heidelberg)"
]

# ╔═╡ 4d3c4167-6640-4d2b-9234-8d62c72385ba
md"""*Server*: $(@bind menu Select([
	shotmenu => "shot.holycross.edu",
	localmenu => "Local host on :8080"
]
))"""

# ╔═╡ c30a839a-906c-44d6-b7cc-c6e50359fee7
md"""*IIIF manifest*: $(@bind manifesturl Select(menu))"""

# ╔═╡ 030f3009-b1f2-40cb-af1f-10e8d83ba413
@htl("""
<script>
new Tify({
  container: '#tify',
  manifestUrl: $manifesturl,
})
</script>
""")

# ╔═╡ 70a787b2-2418-4eb3-b89c-f9e965a68840
localurl = "http://localhost:8080/iiif/complutensian-bne-manifest.json"

# ╔═╡ 946b29b8-7bd9-4adf-b69b-2f98e009f5d1
testmenu = [
	mwe => "local MWE",
	heidelberg => "CP Graec 88 (Heidelberg)"
	
]

# ╔═╡ 8d0c9f1e-d197-41ea-9bc6-dd3c5b117ec4
@bind viewerw Slider(400:50:1000, default = 600, show_value = true)

# ╔═╡ fdee76fa-2835-4108-aff1-8472bcf46111
px = string("height: ", 900, "px")

# ╔═╡ 812642ae-7079-4b71-9142-10a843d479c7
px

# ╔═╡ 5874d391-e175-4ce0-8b5b-0609b56a9284
viewerw

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.5"
PlutoUI = "~0.7.60"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.1"
manifest_format = "2.0"
project_hash = "492f7c87d430f3bc916b9f67d7ebe580fda48e87"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

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
version = "1.11.0"

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
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

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
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

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
version = "1.11.0"

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
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

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
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─d08bd40c-dcd0-4790-a257-33c990e7d74c
# ╟─e642e877-2467-4405-a72c-117b52f59643
# ╟─80cddf00-adec-42c6-9eab-06d8cb0379a8
# ╟─420ba3be-8e4e-11ef-3010-934c9514e951
# ╟─fb037944-4557-4671-9f2a-9db29fabfa1d
# ╟─83ceda56-aa24-4510-82e7-29ca8ba9c79e
# ╟─7eae79ac-5643-46a5-8a9b-2207ef064b64
# ╟─c30a839a-906c-44d6-b7cc-c6e50359fee7
# ╟─29e01b88-75ff-43c2-887e-c4182e52a44b
# ╟─eb508f1b-112a-41b2-8251-0208873e5646
# ╟─5c1f3cbb-f803-4430-adfc-14c71cb0ec2a
# ╟─1a2a30a5-c219-4ff0-9b52-923ab2dd19b5
# ╠═abfa9967-c80b-4e93-b9cd-59e29703a41a
# ╟─b033d55e-a60d-4877-99d8-41467042de40
# ╠═030f3009-b1f2-40cb-af1f-10e8d83ba413
# ╟─fdaf7392-3ce4-4fbf-a836-a43b8db38230
# ╟─74fa184b-b75d-45ce-85a0-572c7d08afcf
# ╟─9d7397e2-5648-4bd5-a54d-700bc1256d6d
# ╟─4fafa095-ad65-4731-9bab-b7265fb42f0e
# ╟─e3ce52f3-349e-4fd7-8980-9e57f6d54ba7
# ╟─2dbc0d34-7d6f-4f71-b486-f40b8f30ca36
# ╟─56a7f320-930f-47d1-a015-2420d23b4b00
# ╟─a81683d3-9178-4bdb-ac98-a87dfd98e2a4
# ╟─3fc0f30c-c710-4af4-887c-0671adbf314a
# ╟─31ec531b-4be6-4a50-a70c-d88a586f9cce
# ╟─ab411ea8-affa-4e86-922e-cb93c5b9e5fd
# ╟─02993c0b-4049-4751-bd88-49f3ad575c71
# ╟─521d62e3-cd46-4e76-8c57-0d4d53fcf6b0
# ╟─afafa3b1-63d5-4e3b-a8c7-d04387fddc5a
# ╟─8073c51e-75a3-42be-a61a-39b7fd7b3d6b
# ╟─7c6d8b3d-b31f-46c5-83bc-043c91a70c36
# ╠═4d3c4167-6640-4d2b-9234-8d62c72385ba
# ╟─bb57547e-ae97-4b8c-879c-1632ce4900ef
# ╟─1bb0882b-bf46-4602-b26c-d334b28f97e8
# ╟─3c449c8e-95ec-4bde-8a50-9e9fc05b5e1b
# ╟─3ae6f9d1-e0e3-4046-a5ef-4c69e1af2411
# ╟─70a787b2-2418-4eb3-b89c-f9e965a68840
# ╟─946b29b8-7bd9-4adf-b69b-2f98e009f5d1
# ╟─8d0c9f1e-d197-41ea-9bc6-dd3c5b117ec4
# ╠═812642ae-7079-4b71-9142-10a843d479c7
# ╠═fdee76fa-2835-4108-aff1-8472bcf46111
# ╠═5874d391-e175-4ce0-8b5b-0609b56a9284
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
