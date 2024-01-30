from pgmpy.inference import CausalInference

import os.path
import pickle
import re
import time
import sys

def run_inference(fpath):
	with open(fpath, 'rb') as f:
		bn, query_var = pickle.load(f)

	f = os.path.basename(fpath)

	out_file = '../results/results.csv'
	outfile_exists = os.path.isfile(out_file) 

	with open(out_file, 'a') as io:
		if not outfile_exists:
			io.write('instance,dom_size,algo,time\n')

		inf = CausalInference(bn)
		start_time = time.time()
		inf.query([query_var], do={}, evidence={}, show_progress=False)
		t = (time.time() - start_time) * 1000
		d = re.search(r'd=(\d+)', f).group(1)
		io.write('{},{},BN,{}\n'.format(f, d, t))

	print('finished')

if __name__ == '__main__':
	run_inference(sys.argv[1])
