import typing
import csv
import random
import math
import statistics
import functools
import collections
import operator

class Patient: 

    def __init__(self, p_inf, num):
        self.infected = random.random() < p_inf
        self.num = num
        self.p_inf = p_inf


    def __str__(self):
        return f"#{self.num}" + "INFECTED" if self.infected else "OK"

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


def perfect_pcr(patients: typing.List[Patient]):
    return any(map(lambda p: p.infected, patients))

p_inf = 1e-3

num = round(math.log(0.5) / math.log(1-p_inf))
"""
def test_group_red(patients):
    test_result = perfect_pcr(patients)

    if not test_result:
        return 1, [False] * len(patients), {patient: 1 for patient in patients}

    if len(patients) == 1:
        return 1, [test_result], {patients[0]: 1}

    middle_index = len(patients) // 2

    a = patients[:middle_index]
    b = patients[middle_index:]

    cnt_a, state_a, tests_taken_a = test_group_red(a)
    end_flg = 0
    while not end_flg:
        if any(state_a):
            cnt_b, state_b, tests_taken_b = test_group_red(b)
        else:
        

    tests_taken = dict(functools.reduce(operator.add, map(collections.Counter, [tests_taken_a, tests_taken_b])))

    return cnt_a + cnt_b, state_a + state_b, tests_taken

def test_group_red(patients):
    middle_index = len(patients) // 2
    a = patients[:middle_index]
    b = patients[middle_index:]

    
    
    test_result = perfect_pcr(patients)

    if not test_result:
        return 1, [False] * len(patients), {patient: 1 for patient in patients}

    if len(patients) == 1:
        return 1, [test_result], {patients[0]: 1}

    

    cnt_a, state_a, tests_taken_a = test_group_red(a)
    end_flg = 0
    while not end_flg:
        if any(state_a):
            cnt_b, state_b, tests_taken_b = test_group_red(b)
        else:
        

    tests_taken = dict(functools.reduce(operator.add, map(collections.Counter, [tests_taken_a, tests_taken_b])))

    return cnt_a + cnt_b, state_a + state_b, tests_taken
"""

def test_group(patients):
    test_result = perfect_pcr(patients)

    if not test_result:
        return 1, [False] * len(patients), {patient: 1 for patient in patients}

    if len(patients) == 1:
        return 1, [test_result], {patients[0]: 1}

    middle_index = len(patients) // 2

    a = patients[:middle_index]
    b = patients[middle_index:]

    cnt_a, state_a, tests_taken_a = test_group(a)
    cnt_b, state_b, tests_taken_b = test_group(b)

    tests_taken = dict(functools.reduce(operator.add, map(collections.Counter, [tests_taken_a, tests_taken_b])))

    return cnt_a + cnt_b, state_a + state_b, tests_taken

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

with open("res.csv", mode="w", newline="") as f:
    wr = csv.writer(f)

    wr.writerow(("p_inf_val", "num_tests_val", "i", "cnt", "tp", "tn", "fp", "fn", "tkn_max", "tkn_mean", "tkn_std"))


    for p_inf_val in p_inf_vals:
        for num_tests_val in num_tests:
            for i in range(num_tests_val):
                
                num_pat = round(math.log(0.5) / math.log(1-p_inf))
                pop = [Patient(p_inf_val, j) for j in range(num_pat)]

                cnt, state, tests_taken = test_group(pop)
                out = eval_test(pop, state, tests_taken)

                row = (p_inf_val, num_tests_val, i, cnt, *out)
                wr.writerow(row)

                #print(row)



# liste von patienten -> ergebnis


# p1, p2, p3, i, r1, r2, r3, r4, r5, r6