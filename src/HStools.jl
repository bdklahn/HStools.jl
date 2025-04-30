module HStools

using JSON3


"""
Roll up the text descriptions included in the levels 8 and 10 details, from the htsdata,
into the decription of the H6 level text.
returns a dictionary with the H6 code as key and the text as value.
Optionally, it can output a markdown file with the H6 codes and their descriptions (default).
"""
function rollupH6(;indir::AbstractString="./", outdir::AbstractString="./", outputmd::Bool=true)
    h6_filepath = joinpath(indir, "H6.json")
    @assert isfile(h6_filepath) "H6.json not found in $indir"
    htsdata_filepath = joinpath(indir, "htsdata.json")
    @assert isfile(htsdata_filepath) "htsdata.json not found in $indir"

    h6_dict = Dict(r.id => r.text for r in JSON3.read(h6_filepath).results if r.aggrlevel == 6 && length(r.id) == 6)
    for r in JSON3.read(htsdata_filepath)
        htsno_parts = split(r.htsno, ".")
        if length(htsno_parts) < 3
            continue
        end
        H6_id = join(htsno_parts[1:2])
        _8_10 = join(htsno_parts[3:end])
        if haskey(r, :description) && !isempty(r.description)
            txt = get(h6_dict, H6_id, "")
            if contains(lowercase(txt), lowercase(r.description))
                @warn "already in $H6_id text: $(r.description)"
                continue
            end
            h6_dict[H6_id] = "$txt; $_8_10 - $(r.description)"
        end
    end
    if outputmd
        md_filepath = joinpath(outdir, "H6_rollup.md")
        open(md_filepath, "w") do io
            for k in sort(collect(keys(h6_dict)))
                println(io, "## H6 Code $k")
                println(io, h6_dict[k])
                println(io, "")
            end
        end
    end
    h6_dict
end
export rollupH6

end # module HStools
