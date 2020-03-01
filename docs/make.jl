using Documenter, 

makedocs(
    modules = [],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "jishnub",
    sitename = ".jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/jishnub/.jl.git",
    push_preview = true
)
