
"""Build a parser for use with Latin texts of Complutensian Bible."""
function parser(tabulaeroot; ortho = "lat25")
    coreds = Tabulae.coredata(tabulaeroot; medieval = true, orthodir = ortho)
    compshared = joinpath(tabulaeroot, "datasets", "complutensian", "complutensian-shared")
    comportho = joinpath(tabulaeroot, "datasets", "complutensian", "complutensian-$(ortho)")
    srcdirs = vcat(coreds.dirs, [compshared, comportho])
    Tabulae.Dataset(srcdirs) |> tsp
end