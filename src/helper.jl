using Serialization

"""
	load_from_file(path::String)

Load a serialized object from the given file.
"""
function load_from_file(path::String)
	io = open(path, "r")
	obj = deserialize(io)
	close(io)
	return obj
end

"""
	save_to_file(obj, path::String)

Serialize an object to a given file.
"""
function save_to_file(obj, path::String)
	open(path, "w") do io
		serialize(io, obj)
	end
end

"""
	nanos_to_millis(t)

Convert a time `t` in nanoseconds to milliseconds.
"""
function nanos_to_millis(t)
	# Nano /1000 -> Micro /1000 -> Milli /1000 -> Second
	return t / 1000 / 1000
end