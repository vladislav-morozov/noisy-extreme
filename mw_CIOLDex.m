% function used to compute optimal confidence interval for extreme quantile or tail
% conditional expectation
% input: X: data (1 by k row vector, descendingly ordered) 
%        h: interested in 1-h/n qunatile or TCE
%        alpha: level of significance
%        est_tce: indicator 0 for quantile 1 for TCE

function [LCL,UCL, successCo, q0Previous, ...
            countPrevious, previousLogFyxTemp]...
            = mw_CIOLDex(X,h,alpha,est_tce)
    k = length(X) ;
    successCo= 1;
    null = load('nulltab') ; alt = load('alttab') ;
    xsi_null = null.mat(1,5:end) ;
    xsi_alt = alt.mat(1,5:end) ;
    
    % find two h values on the grid that are closest to the input
    lgh_grid = (-5:0.5:3) ;
    temp = lgh_grid(log(h)-lgh_grid>0) ;
    h_low = temp(end) ;
    h_high = lgh_grid(find(lgh_grid==h_low)+1) ;
    h_low = exp(h_low) ; h_high = exp(h_high) ;

    k_grid = [5,10,15,20,30,40,50,75,100] ;
    row1 = est_tce*584+1+ (find(lgh_grid==log(h_low))-1)*36 -(log(h_low)==2)*4-(log(h_low)==2.5)*8-(log(h_low)==3)*16 ...
      + (find(k_grid==k)-1)*4 ...
      +(alpha==0.01) + (alpha==0.05)*2+(alpha==0.1)*3 + (alpha==0.2)*4 ; 
    row2 = est_tce*584+1+ (find(lgh_grid==log(h_high))-1)*36 -(log(h_high)==2)*4-(log(h_high)==2.5)*8-(log(h_high)==3)*16 ...
      + (find(k_grid==k)-1)*4 ...
      +(alpha==0.01) + (alpha==0.05)*2+(alpha==0.1)*3 + (alpha==0.2)*4 ; 
    lam1 = null.mat(row1,5:end) ; lam2 = null.mat(row2,5:end) ;
    weight1 = alt.mat(row1,5:end) ; weight2 = alt.mat(row2,5:end) ;
    % linear interpolating the weights
    lam = (h_high-h)/(h_high-h_low)*lam1 + (h-h_low)/(h_high-h_low)*lam2 ;
    weight = (h_high-h)/(h_high-h_low)*weight1 + (h-h_low)/(h_high-h_low)*weight2 ;

    Xs = (X - X(k))./(X(1)-X(k)) ;
    X1 = X(1) ; Xk = X(k) ;
    Log_gx = nan(1,length(xsi_alt)) ;
    for r = 1:length(xsi_alt)
        Log_gx(r) = log_WALgth_fx(Xs,xsi_alt(r)) ;
    end

    Log_fyx_temp = nan(1,length(xsi_null)) ;

    count = 1 ;
    countmax = 201 ;
    q_grid = linspace(-5,5,countmax) ;
    if ceil(h)>k
        hSubs = k; % check if it's possible to take the corresponding tail statistic, otherwise take the maximum available one
    else
        hSubs = ceil(h);
    end
    while count < countmax
       q0_initial = X1*(h<=1)+X(hSubs)*(h>1) + q_grid(count)*(X1-Xk) ;
       % pick a starting point of search
       y = (q0_initial-Xk)./(X1-Xk) ;
       for r = 1:length(xsi_null)               
           q_xsi = (1-est_tce)*(h^(-xsi_null(r))    -1)/xsi_null(r) ...
                     + est_tce*(h^(-xsi_null(r))-1+xsi_null(r))/xsi_null(r)/(1-xsi_null(r)) ;
           Log_fyx_temp(r) = log_fyx_tceOLD(Xs,y,q_xsi,xsi_null(r)) ;               
       end
       if log_WA(Log_gx,log(weight)) < log_WA(Log_fyx_temp,log(lam))
           previousLogFyxTemp = Log_fyx_temp;
          break
       else 
           previousLogFyxTemp = NaN*Log_fyx_temp;
          count = count+1  ; 
       end
    end
   
    if count == countmax
        successCo = 0;
        UCL = -1 ; LCL = -1 ;
        q0Previous = NaN;
        countPrevious = NaN;
    else
    countPrevious = count;
    q0Previous = q0_initial;
    q0_start = q0_initial ;
    q0_L = q0_start*0.5 ;
       while abs(q0_L-q0_start)>0.01
           y = (q0_L -Xk)./(X1-Xk) ;
           for r = 1:length(xsi_null)               
               q_xsi = (1-est_tce)*(h^(-xsi_null(r))-1)/xsi_null(r) ...
                         + est_tce*(h^(-xsi_null(r))-1+xsi_null(r))/xsi_null(r)/(1-xsi_null(r)) ;
               Log_fyx_temp(r) = log_fyx_tceOLD(Xs,y,q_xsi,xsi_null(r)) ;               
           end                 
           if log_WA(Log_gx,log(weight))<log_WA(Log_fyx_temp,log(lam))
               q0_start = q0_L ;
               q0_L = q0_L*0.5 ;
           else
               q0_L = (q0_L+q0_start)/2 ;
           end                      
       end

       q0_start = q0_initial ;
       q0_U = q0_start*2 ;
       while abs(q0_U-q0_start)>0.01
           y = (q0_U -Xk)./(X1-Xk) ;
           for r = 1:length(xsi_null)               
               q_xsi = (1-est_tce)*(h^(-xsi_null(r))-1)/xsi_null(r) ...
                         + est_tce*(h^(-xsi_null(r))-1+xsi_null(r))/xsi_null(r)/(1-xsi_null(r)) ;
               Log_fyx_temp(r) = log_fyx_tceOLD(Xs,y,q_xsi,xsi_null(r)) ;               
           end
           
           if log_WA(Log_gx,log(weight))<log_WA(Log_fyx_temp,log(lam))
               q0_start = q0_U ;
               q0_U = q0_U*2 ;
           else
               q0_U = (q0_U+q0_start)/2 ;
           end                      
       end
    LCL = q0_L ;
    UCL = q0_U ;
    end
 

     
end

