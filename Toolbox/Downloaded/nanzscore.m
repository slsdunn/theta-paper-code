function out = nanzscore(signal,d)


subtractmean = bsxfun(@minus, signal, nanmean(signal,d));
dividebystd  = bsxfun(@rdivide,subtractmean,nanstd(signal,[],d));

out = dividebystd;
  
end


%nanZ = @(X,DIM) bsxfun(@rdivide, bsxfun(@minus, X, nanmean(X,DIM)),nanstd(X,[],DIM));
