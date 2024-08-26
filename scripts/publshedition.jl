using CitableBase
using CitableCorpus
using CitableText
using CitableTeiReaders
using EditionBuilders


repo = pwd()

septlatinxml = joinpath(repo, "editions", "septuagint_latin_genesis.xml")
septlatinxmlcorpus = begin
	readcitable(septlatinxml, CtsUrn("urn:cts:compnov:bible.genesis.sept_latin:"), TEIDivAb, FileReader)
end
lxxbldr = diplomaticbuilder(; versionid = "lxxlatinnormed")
septlatin = edited(lxxbldr, septlatinxmlcorpus)

open("latinglosses.cex", "w") do io
    write(io, cex(septlatin))
end