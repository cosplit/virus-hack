import typing
import csv
import random
import math
import statistics
import functools
import collections
import operator
import itertools

from experiment import Patient, TestFunctionGenerator
from strategies.simple import strategy as test_group

def frange(start, stop=None, step=None):
    # if stop and step argument is None set start=0.0 and step = 1.0
    start = float(start)
    if stop == None:
        stop = start + 0.0
        start = 0.0
    if step == None:
        step = 1.0

    count = 0
    while True:
        temp = float(start + count * step)
        if step > 0 and temp >= stop:
            break
        elif step < 0 and temp <= stop:
            break
        yield temp
        count += 1




perfect_pcr = TestFunctionGenerator(1, 1)


p_inf = 1e-3

num = round(math.log(0.5) / math.log(1-p_inf))


def eval_test(patients, states, tests_taken):
    tp = 0
    tn = 0
    fp = 0
    fn = 0

    for state, patient in zip(states, patients):
        tp += patient.infected and state
        tn += not(patient.infected) and not state
        fp += not(patient.infected) and state
        fn += patient.infected and not state

    tkn_max = max(tests_taken.values())
    tkn_mean = statistics.mean(tests_taken.values())
    tkn_std = statistics.stdev(tests_taken.values())

    return tp, tn, fp, fn, tkn_max, tkn_mean, tkn_std


p_inf_vals = list(frange(0.0001, 0.001, 0.0001))
num_tests = range(10, 100, 25)
test_functions = map(lambda r: TestFunctionGenerator(r, r), frange(0.999, 0.9999, 0.0001))

parameter_space = {
    "p_inf": p_inf_vals,
    "num_tests": num_tests,
    "test_functions": test_functions
}


with open("res.csv", mode="w", newline="") as f:
    wr = csv.writer(f)
    wr.writerow((*parameter_space.keys(), "i", "cnt", "tp", "tn", "fp", "fn", "tkn_max", "tkn_mean", "tkn_std"))

    param_points = list(itertools.product(*parameter_space.values()))

    for params in param_points:
        print(list(zip(parameter_space.keys(), params)))

        p_inf_val, num_tests_val, test_function_val = params

        for i in range(num_tests_val):
            num_pat = round(math.log(0.5) / math.log(1-p_inf))
            pop = [Patient(p_inf_val, j) for j in range(num_pat)]

            cnt, state, tests_taken = test_group(pop, test_function_val)
            out = eval_test(pop, state, tests_taken)

            row = (*params, i, cnt, *out)
            wr.writerow(row)
            #print(row)