
def strategy(patients, test_function):
    cnt, state, tests_taken, _ = strategy_inner(patients, test_function)
    return cnt, state, tests_taken

def strategy_non_est(patients, test_function):
    test_result = test_function(patients)

    if not test_result:
        return 1, [False] * len(patients), {patient: 1 for patient in patients}

    if len(patients) == 1:
        return 1, [test_result], {patients[0]: 1}

    middle_index = len(patients) // 2

    a = patients[:middle_index]
    b = patients[middle_index:]

    cnt_a, state_a, tests_taken_a = strategy_non_est(a, test_function)
    if any(state_a):
        cnt_b, state_b, tests_taken_b = strategy_non_est(b, test_function)
    else:
        cnt_b, state_b, tests_taken_b = strategy_est(b, test_function)
    
    tests_taken = dict(functools.reduce(operator.add, map(collections.Counter, [tests_taken_a, tests_taken_b])))

    return cnt_a + cnt_b, state_a + state_b, tests_taken

def strategy_est(patients, test_function):
    if len(patients) == 1:
        return 1, [True], {patients[0]: 0}

    middle_index = len(patients) // 2
    pats_a = patients[:middle_index]
    pats_b = patients[middle_index:]
    test_result_a = test_function(pats_a)

    if test_result_a:
        test_result_b = test_function(pats_b)
    else:
        test_result_b = strategy_est(pats_b)

    tests_taken = dict(functools.reduce(operator.add, map(collections.Counter, [tests_taken_a, tests_taken_b])))

    if not test_result_a:
        return 1, [False] * len(patients), {patient: 1 for patient in patients}

    return cnt_a + cnt_b, state_a + state_b, tests_taken

