function [entropy] = efficiency_of_a_single_test(p_inf)
%Calculates the entropy for a bernoulli distribution with the probability
%p_inf.
%   If p_inf is a vector or matrix, this function will consider each
%entry as a distribution, while returning the entropy of each distribtion
%in the same shape as the input.
entropy = -p_inf.*log2(p_inf)-(1-p_inf).*log2(1-p_inf);
end

