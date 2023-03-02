function [cq, cl, cu] = quantileBinomialCI(dataVector,q, alphaCI, sorted)
% quantileBinomialCI Computes the qth sample quantile by interpolation and
% returns a binomial (1-alpha)x100% CI. q can be a row vector.


if sorted ~= 1
    dataVector = sort(dataVector);
end
    
    N = length(dataVector);
    R = (N+1)*q;
    r = floor(R);
    f= R-r;
    dataVector(N+1) = dataVector(N);
    dataVector(N+2) = dataVector(N);
    cq = dataVector(r)+f'.*(dataVector(r+1)-dataVector(r));

    t = binoinv(alphaCI, N, q)-1;
    u = binoinv(1-alphaCI, N, q);
    
    g = (alphaCI - binocdf(t, N, q))./(binocdf(t+1, N, q)-binocdf(t, N, q));
    h = (alphaCI - 1 + binocdf(u, N, q))./(binocdf(u, N, q)-binocdf(u-1, N, q));
    
    cl = dataVector(t+1) + g'.*(dataVector(t+2)-dataVector(t+1));
    cu = dataVector(u+1) - h'.*(dataVector(u+1)-dataVector(u));
end