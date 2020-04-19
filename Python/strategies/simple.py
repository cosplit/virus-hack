import functools
import operator
import collections

def strategy(patients, test_function):
    test_result = test_function(patients)

    if not test_result:
        return 1, [False] * len(patients), {patient: 1 for patient in patients}

    if len(patients) == 1:
        return 1, [test_result], {patients[0]: 1}

    middle_index = len(patients) // 2

    a = patients[:middle_index]
    b = patients[middle_index:]

    cnt_a, state_a, tests_taken_a = strategy(a, test_function)
    cnt_b, state_b, tests_taken_b = strategy(b, test_function)

    tests_taken = dict(functools.reduce(operator.add, map(collections.Counter, [tests_taken_a, tests_taken_b])))

    return cnt_a + cnt_b, state_a + state_b, tests_taken