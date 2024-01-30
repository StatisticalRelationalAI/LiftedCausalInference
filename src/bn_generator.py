from pgmpy.models import BayesianNetwork
from pgmpy.factors.discrete import TabularCPD

import pickle

def run_generate(output_dir='../instances/bn/'):
	dom_sizes_employee = [8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096]

	for d_e in dom_sizes_employee:
		d_e_str = f'{d_e:04}' # Pad with zeros to length 4
		out_file = '{}train_rev-d={}.ser'.format(output_dir, d_e_str)
		print('Generating model with |D(E)| = {}'.format(d_e_str))
		bn, query_var = gen_bn_train_rev(d_e)
		with open(out_file, 'wb') as f: # Open in binary mode
			pickle.dump([bn, query_var], f)

def gen_bn_train_rev(d_e):
	edges = []
	for i in range(1, d_e):
		edges.append(('Qual', 'TrainE{}'.format(i)))
		edges.append(('TrainE{}'.format(i), 'CompE{}'.format(i)))
		edges.append(('TrainE{}'.format(i), 'SalE{}'.format(i)))
		edges.append(('CompE{}'.format(i), 'SalE{}'.format(i)))

	bn = BayesianNetwork(edges)

	# g_1 (C: \top)
	qual_cpt = TabularCPD('Qual', 2, [[0.6], [0.4]])

	train_cpts = []

	# g'_2 (C: E == e1)
	train_cpts.append(TabularCPD(
		'TrainE1',
		2,
		[[1.0, 1.0], [0.0, 0.0]],
		evidence=['Qual'],
		evidence_card=[2],
	))

	# g_2 (C: E != e1)
	for i in range(2, d_e):
		train_cpts.append(TabularCPD(
			'TrainE{}'.format(i),
			2,
			[[0.8, 0.3], [0.2, 0.7]],
			evidence=['Qual'],
			evidence_card=[2],
		))

	comp_cpts = []

	# g'_3 (C: E == e1)
	comp_cpts.append(TabularCPD(
		'CompE1',
		2,
		[[0.9, 0.7], [0.1, 0.3]],
		evidence=['TrainE1'],
		evidence_card=[2],
	))

	# g_3 (C: E != e1)
	for i in range(2, d_e):
		comp_cpts.append(TabularCPD(
			'CompE{}'.format(i),
			2,
			[[0.9, 0.7], [0.1, 0.3]],
			evidence=['TrainE{}'.format(i)],
			evidence_card=[2],
		))

	sal_cpts = []

	# g'_4 (C: E == e1)
	sal_cpts.append(TabularCPD(
		'SalE1',
		2,
		[[0.8, 0.5, 0.6, 0.3], [0.2, 0.5, 0.4, 0.7]],
		evidence=['TrainE1', 'CompE1'],
		evidence_card=[2, 2],
	))

	# g_4 (C: E != e1)
	for i in range(2, d_e):
		sal_cpts.append(TabularCPD(
			'SalE{}'.format(i),
			2,
			[[0.8, 0.5, 0.6, 0.3], [0.2, 0.5, 0.4, 0.7]],
			evidence=['TrainE{}'.format(i), 'CompE{}'.format(i)],
			evidence_card=[2, 2],
		))

	bn.add_cpds(qual_cpt, *train_cpts, *comp_cpts, *sal_cpts)

	return [bn, 'SalE1']


if __name__ == '__main__':
	run_generate()