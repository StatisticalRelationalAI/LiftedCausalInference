@isdefined(nanos_to_millis) || include(string(@__DIR__, "/../src/helper.jl"))

"""
	merge_results(outdir=string(@__DIR__, "/../results/"))

Combine the results from all instances into a single CSV file.
"""
function merge_results(outdir=string(@__DIR__, "/../results/"))
	file_bn  = string(outdir, "results.csv")
	file_pfg = string(outdir, "_stats.csv")

	open(string(outdir, "merged.csv"), "w") do io
		write(io, "instance,dom_size,algo,time\n")
		open(file_bn, "r") do in_io
			readline(in_io) # Remove header
			for line in readlines(in_io)
				line_split = split(line, ",")
				line_split[1] = replace(line_split[1], ".ser" => "")
				write(io, string(join(line_split, ","), "\n"))
			end
		end
		open(file_pfg, "r") do in_io
			readline(in_io) # Remove header
			for line in readlines(in_io)
				line_split = split(line, ",")
				f = line_split[2]
				d = parse(Int, match(r"d=(\d+)", f)[1])
				a = line_split[1]
				t = nanos_to_millis(parse(Float64, line_split[12]))
				write(io, "$f,$d,$a,$t\n")
			end
		end
	end
end

merge_results()