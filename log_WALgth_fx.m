% function used to compute the log conditional expectation of the length
% times the density of Xs
function out = log_WALgth_fx(xs,xsi)
[nsim,k] = size(xs) ;
nGQ = 100 ;
if xsi == 0
    display('xsi == 0')
%    out = 2*log(gamma(k)) - k*log( sum( [ones(nsim,1),xs,zeros(nsim,1)] ,2) ) ;
elseif xsi > 0
   [u,w] = lgwt(nGQ,0,1) ; A = gpinv(u,xsi,1,0) ;
   P1 = (k-1)*log(A')-log(gppdf(A',xsi,1,0)) ;
   P2 = -(1+1/xsi)*reshape(sum(log(1+ kron(xs,A)*xsi),2),nGQ,nsim)' ; % nsim x nGQ 
   H0 = repmat(P1,nsim,1) + P2  + log(repmat(w',nsim,1)) ;
   mH0 =  max(H0,[],2) ;
   out = log(gamma(k-xsi)) + mH0 + log (sum( exp (H0 - repmat(mH0,1,nGQ ) ),2)) ;
else
   [h,w] = lgwt(nGQ,0,-1/xsi) ;
   P1 = (k-1)*log(h') ;
   P2 = -(1+1/xsi)*reshape(sum(log(1+ kron(xs,h)*xsi),2),nGQ,nsim)' ; % nsim x nGQ 
   H0 = repmat(P1,nsim,1) + P2  + log(repmat(w',nsim,1)) ;
   mH0 =  max(H0,[],2) ;
   out = log(gamma(k-xsi)) + mH0 + log (sum( exp (H0 - repmat(mH0,1,nGQ) ),2)) ;
end
   
end