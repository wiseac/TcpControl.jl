using Documenter
using TcpInstruments


makedocs(;
    modules = [TcpInstruments],
    repo="https://github.com/Orchard-Ultrasound-Innovation/TcpInstruments.jl/blob/{commit}{path}#{line}",
    sitename = "TcpInstruments.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical="https://Orchard-Ultrasound-Innovation.github.io/TcpInstruments.jl",
        assets=String[],
    ),
    pages = [
        "Home" => "index.md",
        "Manual" => Any[
            "Supported Instruments" => "instruments.md",
            "General Functions" => "general_functions.md",
            "Instrument-specific Functions" => "instrument_functions.md",
        ]
    ],
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/Orchard-Ultrasound-Innovation/TcpInstruments.jl.git",
    devbranch="main",
)
