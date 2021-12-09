function [binned, varargout] = bin_data_wrt_first_col(dataIn, binEdges, varsIn, varargin)

%
%[binned, varargout] = bin_data_wrt_first_col(dataIn, binEdges, varsIn)
%
%

try

nanidx = any(isnan(dataIn),2);
dataIn(nanidx,:) = [];    

if nargin == 4  % extra argument for equalising number of datapoints in each bin
    if varargin{1}
        [dataIn,sampleidx] = equalise_nsamples_in_each_bin(dataIn,binEdges);
    else
        sampleidx(:,1) = 1:size(dataIn,1);
    end
else
    sampleidx(:,1) = 1:size(dataIn,1);
end

binlabels = discretize(dataIn(:,1),binEdges);
binIDs = unique(binlabels);
binIDs(isnan(binIDs))=[];

n_in_bin = NaN(size(binIDs));
for n = 1:numel(binIDs)
   n_in_bin(n) =  sum(binlabels==binIDs(n));
end
min_n    = min(n_in_bin);
subindex = NaN(min_n*numel(binIDs),1);

for n = 1:numel(binIDs)
    idx1 = 1 + ((n-1)*min_n);
    idx2 = idx1 + min_n -1;
    binindices = find(binlabels==binIDs(n));    
    if n_in_bin(n) == min_n
        subindex(idx1:idx2) = binindices;
    else
        subindex(idx1:idx2) = randsample(binindices,min_n,false);
    end  
end
subData = dataIn(subindex,:);



varnames = make_varnames(varsIn);

binned = makeBinnedTbl(varnames);
nrow = 1;


for nb = 1 : numel(binIDs)
    binID = binIDs(nb);
    
    binData = dataIn(binlabels==binID,:);
        
    binnedData  = bin_variable(binData); % calc averages for each bin
    
    binnedmdata(1,1) = size(binData,1);  % n points in bin
    binnedmdata(1,2) = binEdges(binID);  % bin edges
    binnedmdata(1,3) = binEdges(binID+1);
    
    binnedData = [binnedmdata binnedData];
    
    binned(nrow,:) = array2table(binnedData);
    
    nrow = nrow+1;
end

if nargout > 1
    [~, idx]  = sort(dataIn(:,1));
    sorted    = dataIn(idx,:);
    sortedlbl = binlabels(idx); 
    sortedidx = sampleidx(idx);
    dataOut = [sortedlbl sorted sortedidx];
    varargout{1} = dataOut;
end


catch err
    parseError(err)
    keyboard
end
end


function [subData,subindex] = equalise_nsamples_in_each_bin(dataIn,binEdges)

binlabels = discretize(dataIn(:,1),binEdges);
binIDs = unique(binlabels);
binIDs(isnan(binIDs))=[];

n_in_bin = NaN(size(binIDs));
for n = 1:numel(binIDs)
   n_in_bin(n) =  sum(binlabels==binIDs(n));
end
min_n    = min(n_in_bin);
subindex = NaN(min_n*numel(binIDs),1);

for n = 1:numel(binIDs)
    idx1 = 1 + ((n-1)*min_n);
    idx2 = idx1 + min_n -1;
    binindices = find(binlabels==binIDs(n));    
    if n_in_bin(n) == min_n
        subindex(idx1:idx2) = binindices;
    else
        subindex(idx1:idx2) = randsample(binindices,min_n,false);
    end  
end
subData = dataIn(subindex,:);
end


function varnames = make_varnames(varsIn)

prefixes = {'mean','std','median','pct25','pct75','iqr','pct9','pct91','min','max'};
C        = cell(size(prefixes));
varnames = [];

for n = 1:numel(varsIn)
    v = varsIn{n};
    Cv = C;
    Cv(:) = {v};
    
    varnames = [varnames cellfun(@horzcat,prefixes,Cv,'UniformOutput',0)];
end

varnames = horzcat({'ndatapoints','bin1','bin2'}, varnames);

end

function T = makeBinnedTbl(varnames)

tableParams    = cell(1,numel(varnames));
tableParams(:) = {NaN};

T = table(tableParams{:});
T.Properties.VariableNames = varnames;

end


function   binnedmat = bin_variable(binData)

binnedmat(1,:)  = mean(binData,1);
binnedmat(2,:)  = std(binData,[],1);
binnedmat(3,:)  = median(binData,1);
binnedmat(4,:)  = prctile(binData,25,1);
binnedmat(5,:)  = prctile(binData,75,1);
binnedmat(6,:)  = binnedmat(5,:) - binnedmat(4,:);
binnedmat(7,:)  = prctile(binData,9,1); 
binnedmat(8,:)  = prctile(binData,91,1);
binnedmat(9,:)  = min(binData,[],1);
binnedmat(10,:) = max(binData,[],1);

binnedmat = reshape(binnedmat,1,[]);

end



