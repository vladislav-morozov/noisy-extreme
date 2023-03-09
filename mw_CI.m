% function used to compute optimal confidence interval for extreme quantile or tail
% conditional expectation
% input: X: data (1 by k row vector, descendingly ordered) 
%        h: interested in 1-h/n qunatile or TCE
%        alpha: level of significance


function [LCL, UCL, constructionSuccess,  previousSuccess, q0Previous, ...
            countPrevious, previousLogFyxTemp, q0Lprevious, q0Uprevious]...
            = mw_CI(X,h,alpha, glPoints, glLP, previousSuccess, q0Previous, ...
            countPrevious, previousLogFyxTemp, q0Lprevious, q0Uprevious)
    
    
    % Initialize parameters
    constructionSuccess = 1;  % assume by default that interval works
    k = length(X) ;
    
    % This can be optimized for simulations and be passed to the function
    null = load('nulltab') ; alt = load('alttab') ;
    xi_null = null.mat(1,5:end) ; % this is just an even grid
    xi_alt = alt.mat(1,5:end) ; % who knows
    
    % find two h values on the grid that are closest to the input
    lgh_grid = (-5:0.5:3) ;
    temp = lgh_grid(log(h)-lgh_grid>0) ;
    h_low = temp(end) ;
    h_high = lgh_grid(find(lgh_grid==h_low)+1) ;
    h_low = exp(h_low) ; h_high = exp(h_high) ;

    k_grid = [5,10,15,20,30,40,50,75,100] ;
    % These row things are looking something up
    row1 = 1+ (find(lgh_grid==log(h_low))-1)*36 -(log(h_low)==2)*4-(log(h_low)==2.5)*8-(log(h_low)==3)*16 ...
      + (find(k_grid==k)-1)*4 ...
      +(alpha==0.01) + (alpha==0.05)*2+(alpha==0.1)*3 + (alpha==0.2)*4 ; 
    row2 = 1+ (find(lgh_grid==log(h_high))-1)*36 -(log(h_high)==2)*4-(log(h_high)==2.5)*8-(log(h_high)==3)*16 ...
      + (find(k_grid==k)-1)*4 ...
      +(alpha==0.01) + (alpha==0.05)*2+(alpha==0.1)*3 + (alpha==0.2)*4 ; 
  
    % here the things are extracting something. First seems to be the
    % Lambda weights for given k and confidence level
    lam1 = null.mat(row1,5:end) ; lam2 = null.mat(row2,5:end) ;
    weight1 = alt.mat(row1,5:end) ; weight2 = alt.mat(row2,5:end) ;
    % linear interpolating the weights
    lam = (h_high-h)/(h_high-h_low)*lam1 + (h-h_low)/(h_high-h_low)*lam2 ;
    weight = (h_high-h)/(h_high-h_low)*weight1 + (h-h_low)/(h_high-h_low)*weight2 ;

    Xs = (X - X(k))./(X(1)-X(k)) ;
    X1 = X(1) ;
    Xk = X(k) ;
    
 
    Log_gx = nan(1,length(xi_alt)) ;
    for r = 1:length(xi_alt)
        Log_gx(r) = log_WALgth_fx(Xs,xi_alt(r)) ;
    end

    Log_fyx_temp = nan(1,length(xi_null)) ;
    countmax = 201 ;
    q_grid = linspace(-5,5,countmax) ;
    if ceil(h)>k
        hSubs = k; % check if it's possible to take the corresponding tail statistic, otherwise take the maximum available one
    else
        hSubs = ceil(h);
    end
            
    if isempty(previousSuccess)
        previousSuccess=0;
    end
    
    if  previousSuccess ==1 % Check if there is a previous run in the workspace
        % Check if the previous run is good with the current weights
        if log_WA(Log_gx,log(weight)) < log_WA(previousLogFyxTemp,log(lam)) && previousSuccess==1
            Log_fyx_temp = previousLogFyxTemp;
            q0_initial= q0Previous;
            count = countPrevious;
        % Otherwise try to continue it
        else
            count = max(1, countPrevious-15);
            while count < countmax
                q0_initial = X1*(h<=1)+X(hSubs)*(h>1) + q_grid(count)*(X1-Xk) ;
                % pick a starting point of search
                y = (q0_initial-Xk)./(X1-Xk) ;
                for r = 1:length(xi_null)
                    q_xi =  (h^(-xi_null(r))-1)/xi_null(r) ;
                    Log_fyx_temp(r) = log_fyx_tce(Xs,y,q_xi,xi_null(r), glPoints, glLP) ;
                end
                if log_WA(Log_gx,log(weight)) < log_WA(Log_fyx_temp,log(lam))
                    previousSuccess =  1;
                    previousLogFyxTemp = Log_fyx_temp; 
                    q0Previous = q0_initial;
                    countPrevious = count;
                    break
                else
                    count = count+1  ;
                end
            end
        end
        
    % If no previous run exists, start from zero
    else 
        count = 1 ;
        while count < countmax
            q0_initial = X1*(h<=1)+X(hSubs)*(h>1) + q_grid(count)*(X1-Xk) ;
            % pick a starting point of search
            y = (q0_initial-Xk)./(X1-Xk) ;
            for r = 1:length(xi_null)
                q_xi = (h^(-xi_null(r))-1)/xi_null(r) ;
                Log_fyx_temp(r) = log_fyx_tce(Xs,y,q_xi,xi_null(r), glPoints, glLP) ;
            end
            if log_WA(Log_gx,log(weight)) < log_WA(Log_fyx_temp,log(lam))
                previousSuccess =  1;
                previousLogFyxTemp = Log_fyx_temp; 
                q0Previous = q0_initial;
                countPrevious = count;
                break
            else
                count = count+1  ;
            end
        end
    end
   
    if count == countmax
        % Construction fails
        previousSuccess = 0;
        constructionSuccess = 0;
        UCL = -1 ; LCL = -1 ;
    else
        
        % This constructs the intervals
        % As h increases, the quantile of interest decreases. On the same
        % dataset, the bounds should be decreasing. It makes sense to reuse
        % previous values
        if length(q0Lprevious)==1 && previousSuccess==1 % Initialize with previous values
            q0_start = q0Lprevious ;
            q0_L = q0_start*0.995 ;
            while abs(q0_L-q0_start)>0.001
                y = (q0_L -Xk)./(X1-Xk) ;
                for r = 1:length(xi_null)
                    q_xi = (h^(-xi_null(r))-1)/xi_null(r) ;
                    Log_fyx_temp(r) = log_fyx_tce(Xs,y,q_xi,xi_null(r), glPoints, glLP) ;
                end
                if log_WA(Log_gx,log(weight))<log_WA(Log_fyx_temp,log(lam))
                    q0_start = q0_L ;
                    q0_L = q0_L*0.995 ;
                else
                    q0_L = (q0_L+q0_start)/2 ;
                    q0Lprevious = q0_L;
                end
            end
            
            q0_start = q0Uprevious ;
            q0_U = q0_start*0.9 ;
            while abs(q0_U-q0_start)>0.001
                  y = (q0_U -Xk)./(X1-Xk) ;
                for r = 1:length(xi_null)
                    q_xi = (h^(-xi_null(r))-1)/xi_null(r);
                    Log_fyx_temp(r) = log_fyx_tce(Xs,y,q_xi,xi_null(r), glPoints, glLP) ;
                end
                
                if log_WA(Log_gx,log(weight))<log_WA(Log_fyx_temp,log(lam))
                    q0_start = q0_U ;
                    q0_U = q0_U*1.01  ;
                else
                    q0_U = (q0_U+q0_start)/2 ;
                    q0Uprevious = q0_U;
                end
            end
            LCL = q0_L ;
            UCL = q0_U ;
        else % don't inialize with previous values
            q0_start = q0_initial ;
            q0_L = q0_start*0.5 ;
            while abs(q0_L-q0_start)>0.001
                y = (q0_L -Xk)./(X1-Xk) ;
                for r = 1:length(xi_null)
                    q_xi = (h^(-xi_null(r))-1)/xi_null(r) ;
                    Log_fyx_temp(r) = log_fyx_tce(Xs,y,q_xi,xi_null(r), glPoints, glLP) ;
                end
                if log_WA(Log_gx,log(weight))<log_WA(Log_fyx_temp,log(lam))
                    q0_start = q0_L ;
                    q0_L = q0_L*0.5 ;
                else
                    q0_L = (q0_L+q0_start)/2 ;
                    q0Lprevious = q0_L;
                end
            end
            
            q0_start = q0_initial ;
            q0_U = q0_start*2 ;
            while abs(q0_U-q0_start)>0.001
                y = (q0_U -Xk)./(X1-Xk) ;
                for r = 1:length(xi_null)
                    q_xi = (h^(-xi_null(r))-1)/xi_null(r);
                    Log_fyx_temp(r) = log_fyx_tce(Xs,y,q_xi,xi_null(r), glPoints, glLP) ;
                end
                
                if log_WA(Log_gx,log(weight))<log_WA(Log_fyx_temp,log(lam))
                    q0_start = q0_U ;
                    q0_U = q0_U*2 ;
                else
                    q0_U = (q0_U+q0_start)/2 ;
                    q0Uprevious = q0_U;
                end
            end
            LCL = q0_L ;
            UCL = q0_U ;
        end
    end

     
end

