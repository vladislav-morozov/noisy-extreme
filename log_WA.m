function out = log_WA(log_pdf,log_weight)
  [n,dim_ksi] = size(log_weight) ;

  mlog_pdf = max(log_pdf+log_weight,[],2) ;
  out = log(sum(exp(log_pdf+log_weight - repmat(mlog_pdf,1,dim_ksi)),2)) + mlog_pdf ;

end