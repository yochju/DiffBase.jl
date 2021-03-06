using Documenter, DiffBase

makedocs(modules=[DiffBase],
         doctest = false,
         format = :html,
         sitename = "DiffBase",
         pages = ["Introduction" => "index.md",
                  "DiffResult API" => "diffresultapi.md"])

deploydocs(repo = "github.com/JuliaDiff/DiffBase.jl.git",
           osname = "linux",
           julia = "0.6",
           target = "build",
           deps = nothing,
           make = nothing)
