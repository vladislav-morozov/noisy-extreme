function [glPointsNew, glWeightsNew] = glRescaler(y, Lp, a ,b)

% Linear map from[-1,1] to [a,b]
glPointsNew=(a*(1-y)+b*(1+y))/2;
% Compute the weights
N1 = length(glPointsNew);
N2 = N1+1;
glWeightsNew=(b-a)./((1-y.^2).*Lp.^2)*(N2/N1)^2;

end