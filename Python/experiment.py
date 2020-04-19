import typing
import random

class Patient: 
    def __init__(self, p_inf, num):
        self.infected = random.random() < p_inf
        self.num = num
        self.p_inf = p_inf

    def __str__(self):
        return f"#{self.num}" + "INFECTED" if self.infected else "OK"

class TestFunctionGenerator:
    def __init__(self, sensitivity, specificity):
        self.sensitivity = sensitivity
        self.specificity = specificity

    def __call__(self, patients):
        actual_result = any(map(lambda p: p.infected, patients))

        if actual_result:
            return random.random() < self.sensitivity
        else:
            return random.random() > self.specificity

    def __repr__(self):
        return f"sensitivity={self.sensitivity},specificity={self.specificity}"