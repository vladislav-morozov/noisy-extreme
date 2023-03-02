function a = noisyExtreme_gaussianKernelDerivative(x)
% Computes the derivative of the standard Gaussian kernel


    a= 1/sqrt(2*pi).*(-x).*exp(-1/2*x.^2);
end