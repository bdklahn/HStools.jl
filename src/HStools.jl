module HStools

using JSON3

function load_HX(;dirpath::AbstractString="./", filename::AbstractString="H6.json")
    filepath = joinpath(dirpath, filename)
    if !isfile(filepath)
        error("File not found: $filepath")
    end
    return JSON3.read(filepath)
end
export load_HX

function h6_id_text(hsjson3)
    r = hsjson3.results
    return Dict(r.id => r.text for r in r if r.aggrlevel == 6 && length(r.id) == 6)
end
export h6_id_text

function rollup(;h6_id_text::Dict, htsdata_json3::JSON3.Array)
    for r in htsdata_json3
        htsno_parts = split(r.htsno, ".")
        if length(htsno_parts) < 3
            continue
        end
        H6_id = join(htsno_parts[1:2])
        rest = join(htsno_parts[3:end])
        if haskey(r, :description) && !isempty(r.description)
            txt = get(h6_id_text, H6_id, "")
            if contains(lowercase(txt), lowercase(r.description))
                @warn "already in $H6_id text: $(r.description)"
                continue
            end
            @show h6_id_text[H6_id] = "$txt; $rest - $(r.description)"
        end
    end
    h6_id_text
end
export rollup

function dct_to_md(;d::Dict, filepath::AbstractString)
    kees = sort(collect(keys(d)))
    open(filepath, "w") do io
        for k in kees
            println(io, "## H6 Code $k")
            println(io, d[k])
            println(io, "")
        end
    end
end
export dct_to_md

function rollupdown(;h6_filepath::AbstractString="./H6.json",
                    htsdata_filepath::AbstractString="./htsdata.json",
                    md_filepath::AbstractString="./H6_rollup.md")
    h6_json3 = load_HX(dirpath=dirname(h6_filepath), filename=basename(h6_filepath))
    h6_id_txt = h6_id_text(h6_json3)
    htsdata_json3 = JSON3.read(htsdata_filepath)
    h6_id_txt = rollup(h6_id_text=h6_id_txt, htsdata_json3=htsdata_json3)
    dct_to_md(;d=h6_id_txt, filepath=md_filepath)
end
export rollupdown

end # module HStools
