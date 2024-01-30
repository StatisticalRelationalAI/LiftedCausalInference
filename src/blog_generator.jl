using Dates

"""
	run_generate(output_dir=string(@__DIR__, "/../instances/pfg/"))

Generate the (par)factor graph instances used in the evaluation.
"""
function run_generate(output_dir=string(@__DIR__, "/../instances/pfg/"))
	start = Dates.now()

	dom_sizes_employee = [8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096]

	for d_e in dom_sizes_employee
		d_e_str = lpad(d_e, 4, "0")
		@info "Generating model with |D(E)|=$d_e_str"
		gen_blog_train_rev(
			d_e,
			string(output_dir, "train_rev-d=$d_e_str.blog")
		)
	end

	@info "=> Start:      $start"
	@info "=> End:        $(Dates.now())"
	@info "=> Total time: $(Dates.now() - start)"
end

"""
	gen_blog_train_rev(d_e::Int, file::AbstractString)

Generate a (par)factor graph for the train-rev model with domain size `d_e`
in Bayesian logic (BLOG) syntax and save it to the file `file`.
"""
function gen_blog_train_rev(d_e::Int, file::AbstractString)
	open(file, "w") do io
		write(io, "type Employee;\n\n")

		write(io, "guaranteed Employee e[$d_e];\n\n")

		write(io, "random Boolean Qual;\n")
		write(io, "random Boolean Train(Employee);\n")
		write(io, "random Boolean Comp(Employee);\n")
		write(io, "random Boolean Sal(Employee);\n\n")

		# g_1 (C: \top)
		write(io, "factor MultiArrayPotential[[0.6, 0.4]]\n\t(Qual);\n\n")

		# g'_2 (C: E == e1)
		write(io, "parfactor Employee E : ")
		for i in 2:d_e
			write(io, string("E != e$i", i < d_e ? " & " : ". "))
		end
		write(io, "MultiArrayPotential[[1.0, 0.0, 1.0, 0.0]]\n\t(Qual, Train(E));\n\n")

		# g_2 (C: E != e1)
		write(io, "parfactor Employee E : E != e1. MultiArrayPotential[[0.8, 0.2, 0.3, 0.7]]\n\t(Qual, Train(E));\n\n")

		# g'_3 (C: E == e1)
		write(io, "parfactor Employee E : ")
		for i in 2:d_e
			write(io, string("E != e$i", i < d_e ? " & " : ". "))
		end
		write(io, "MultiArrayPotential[[0.9, 0.1, 0.7, 0.3]]\n\t(Train(E), Comp(E));\n\n")

		# g_3 (C: E != e1)
		write(io, "parfactor Employee E : E != e1. MultiArrayPotential[[0.9, 0.1, 0.7, 0.3]]\n\t(Train(E), Comp(E));\n\n")

		# g'_4 (C: E == e1)
		write(io, "parfactor Employee E : ")
		for i in 2:d_e
			write(io, string("E != e$i", i < d_e ? " & " : ". "))
		end
		write(io, "MultiArrayPotential[[0.8, 0.2, 0.5, 0.5, 0.6, 0.4, 0.3, 0.7]]\n\t(Train(E), Comp(E), Sal(E));\n\n")

		# g_4 (C: E != e1)
		write(io, "parfactor Employee E : E != e1. MultiArrayPotential[[0.8, 0.2, 0.5, 0.5, 0.6, 0.4, 0.3, 0.7]]\n\t(Train(E), Comp(E), Sal(E));\n\n")

		write(io, "query Sal(e1);")
	end
end

run_generate()