% function used to compute the log density of Ys and Xs
function out = log_fyx_tceOLD(xs,ys,q,xi)
[nsim,k] = size(xs) ;
nGQ = 20 ;
  P4 = nan(nsim,nGQ) ;    
  xlow = (1000^(-xi)-1)/xi ;
      if xi>0
         if min(ys)>0 && max(-1/xi,xlow)>q
             I = -1000*ones(nsim,1) ;
         else
             if min(ys)>0
                [s1,w1] = lgwt(nGQ,max(-1/xi,xlow),q) ; 
                s = repmat(s1',nsim,1);  w = repmat(w1',nsim,1) ;
              
             elseif max(ys)<0
                [s2,w2] = lgwt(nGQ,gpcdf(max([q,-1/xi,xlow]),xi,3,max([q,-1/xi,xlow])),1) ;
                s2 = gpinv(s2,xi,3,max([q,-1/xi,xlow])) ;
                s = repmat(s2',nsim,1);  w = repmat(w2',nsim,1) ;   
             
             else
                [s1,w1] = lgwt(nGQ,max(-1/xi,xlow),q) ;
                [s2,w2] = lgwt(nGQ,gpcdf(max([q,-1/xi,xlow]),xi,3,max([q,-1/xi,xlow])),1) ;
                s2 = gpinv(s2,xi,3,max([q,-1/xi,xlow])) ;
                s = repmat(s1',nsim,1);  w = repmat(w1',nsim,1) ;     
                s(ys<0,:) = repmat(s2',length(find(ys<0)),1) ;
                w(ys<0,:) = repmat(w2',length(find(ys<0)),1) ;
             end
             P1 = -exp(-1/xi*log1p(xi*s)) ; % n x nGQ
             P2 = (k-1)*( log(abs(q-s)) - repmat(log(abs(ys)),1,nGQ) ); % n x nGQ
             P3 = -repmat(log(abs(ys)),1,nGQ) ; % n x nGQ
             P3((ys<0),:) = -log(gppdf(s((ys<0),:),xi,1,max([q,-1/xi,xlow]))) + P3((ys<0),:) ;
             for l = 1:nGQ
                 P4(:,l) = -(1+1/xi)*sum(log1p(xi*(repmat(s(:,l),1,k)+xs./repmat(ys,1,k).*repmat(q-s(:,l),1,k))),2) ; % n x nGQ 
             end
             H0 = P1 + P2 + P3 + P4 + log(w) ;
 %          H0(find(isnan(s(:,1))),:) = -1e-10*ones(length(find(isnan(s(:,1)))),nGQ) ;             
             mH0 =  max(H0,[],2) ;
             I  =  mH0 + log (sum( exp (H0 - repmat(mH0,1,nGQ ) ),2)) ;
         end
         
      elseif xi < 0
          s = nan(nGQ,nsim) ;
          w = nan(nGQ,nsim) ;
          
          for j = 1:nsim
              if ys(j)<0
                  [s(:,j),w(:,j)] = lgwt(nGQ,max(q,xlow),(ys(j)+xi*q)/xi/(1-ys(j))) ;                       
              elseif ys(j)>0&&ys(j)<1
                  [s(:,j),w(:,j)] = lgwt(nGQ,max((ys(j)+xi*q)/xi/(1-ys(j)),xlow),q) ;
              else
                  if xlow > min([q,-1/xi,(ys(j)+xi*q)/xi/(1-ys(j))])
                     s(:,j) = ones(nGQ,1)*(min([q,-1/xi,(ys(j)+xi*q)/xi/(1-ys(j))])-1) ;
                     w(:,j) = ones(nGQ,1)/nGQ ;
                  else
                     [s(:,j),w(:,j)] = lgwt(nGQ,xlow,min([q,-1/xi,(ys(j)+xi*q)/xi/(1-ys(j))])) ;    
                  end
                  %%%%% possibly complex number if xlow >
                  %%%%% min([q,-1/xi,(ys(j)+xi*q)/xi/(ys(j)-1)]), then
                  %%%%% correct this in the end
              end
          end
          s = s' ; w = w' ; 
           P1 = -exp(-1/xi*log1p(xi*s)) ; % n x nGQ          
           P2 = (k-1)* ( log(abs(q-s))-repmat(log(abs(ys)),1,nGQ) ); % n x length(s)
           P3 = - repmat(log(abs(ys)),1,nGQ) ; % n x length(s)
           for l = 1:nGQ
               P4(:,l) = -(1+1/xi)*sum(log1p(xi*(repmat(s(:,l),1,k)+xs./repmat(ys,1,k).* repmat(q-s(:,l),1,k))),2) ; % n x nGQ 
           end
           H0 = P1 + P2 + P3 + P4 + log(w) ;
%           H0(find(isnan(s(:,1))),:) = -1e-10*ones(length(find(isnan(s(:,1)))),nGQ) ;        
           mH0 =  max(H0,[],2) ;
           I = mH0 + log (sum( exp (H0 - repmat(mH0,1,nGQ ) ),2)) ;
           
         
           


      end
      % correct for two cases when xi<0:           
      % 1, y<0 q>(ys(j)+xi*q)/xi/(1-ys(j))   
      % 2, 0<y<1 q<(ys(j)+xi*q)/xi/(1-ys(j)) 
      % correct for one case when xi>0:
      % 1, y>0, -1/xi>q
           
      for j = 1:nsim
 
          if xi<0     
             if ys(j)<0 && q>(ys(j)+xi*q)/xi/(1-ys(j)) 
                I(j) = -1000 ;             
             elseif 0<ys(j)&&ys(j)<1 && q< max(xlow,(ys(j)+xi*q)/xi/(1-ys(j)))
                I(j) = -1000 ;  
             elseif ys(j)>1 && min([q,-1/xi,(ys(j)+xi*q)/xi/(1-ys(j))]) <xlow
                I(j) = -1000 ;
             end
          else
              if ys(j)>0 &&  max(-1/xi,xlow)>q
                  I(j) = -1000 ;
              end
                  
          end
      end
      
      
  out = I ;
end


    