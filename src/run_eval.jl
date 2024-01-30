@isdefined(save_to_file) || include(string(@__DIR__, "/helper.jl"))

"""
	run_eval(
		dir=string(@__DIR__, "/../instances/"),
		outdir = string(@__DIR__, "/../results/"),
		jar_file=string(dir, "/ljt-v1.0-jar-with-dependencies.jar")
	)

Run the empirical evaluation on the instances in the directory `dir`.
The results are saved in the directory `outdir` (note that another program file
is called which uses the same output directory).
The Java program `jar_file` is used to run some of the inference algorithms.
"""
function run_eval(
	dir=string(@__DIR__, "/../instances/"),
	outdir = string(@__DIR__, "/../results/"),
	jar_file=string(dir, "/ljt-v1.0-jar-with-dependencies.jar")
)
	outfile = string(outdir, "/results.csv")

	for (root, dirs, files) in walkdir(dir)
		for f in files
			(!occursin(".DS_Store", f) && !occursin("README", f) &&
				!occursin(".gitkeep", f) && !endswith(f, ".jar")) || continue

			fpath = string(root, endswith(root, "/") ? "" : "/", f)
			d = parse(Int, match(r"d=(\d+)", f)[1])
			@info "Processing file '$fpath'..."

			if endswith(f, ".blog")
				for engine in ["ve.VarElimEngine", "fove.LiftedVarElim"]
					cmd = `java -jar $jar_file -e $engine -o $outdir $fpath`
					output = run_with_timeout(cmd)
					write_output(output, outfile, f, d, engine)
				end
			elseif endswith(f, ".ser")
				cmd = `python3 bn_inference.py $fpath`
				output = run_with_timeout(cmd)
				write_output(output, outfile, f, d, "BN")
			else
				@error "Unknown file type: '$fpath'"
			end
		end
	end
end


"""
	run_with_timeout(command, timeout::Int = 3600)

Run an external command with a timeout. If the command does not finish within
the specified timeout, the process is killed and `timeout` is returned.
"""
function run_with_timeout(command, timeout::Int = 3600)
	out = Pipe()
	cmd = run(pipeline(command, stdout=out); wait=false)
	close(out.in)
	for _ in 1:timeout
		!process_running(cmd) && return read(out, String)
		sleep(1)
	end
	kill(cmd)
	return "timeout"
end

"""
	write_output(
		output::AbstractString,
		outfile::AbstractString,
		f::AbstractString,
		d::Int,
		a::AbstractString
	)

If `output` is `timeout`, append a line to `outfile` with the instance name
`f`, the domain size `d`, the algorithm `a`, and the string `timeout` as time.
"""
function write_output(
	output::AbstractString,
	outfile::AbstractString,
	f::AbstractString,
	d::Int,
	a::AbstractString
)
	if output == "timeout"
		outfile_exists = isfile(outfile)
		open(outfile, "a") do io
			!outfile_exists && write(io, "instance,dom_size,algo,time\n")
			write(io, "$f,$d,$a,timeout\n")
		end
	end
end

run_eval()