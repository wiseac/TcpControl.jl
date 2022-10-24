using Documenter
using TcpInstruments


makedocs(
    sitename = "TcpInstruments",
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    pages = [
        "Home" => "index.md",
        "Manual" => Any[
            "Supported Instruments" => "instruments.md",
            "General Functions" => "general_functions.md",
            "Instrument-specific Functions" => "instrument_functions.md",
        ]
    ],
    modules = [TcpInstruments]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/Orchard-Ultrasound-Innovation/TcpInstruments.jl.git",
    branch = "gh-pages",
    target = "build",
)
