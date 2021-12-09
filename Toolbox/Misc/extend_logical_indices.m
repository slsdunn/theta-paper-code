function outIdx = extend_logical_indices(inputIdx, extval)

%
% inputIdx = matrix of logcial indices where each column is a channel
% extval = number of samples around each NaN that is to be removed
%
% Soraya Dunn 2020
%

mmean = movmean(inputIdx,extval*2);

outIdx = mmean > 0;

%% sanity check
% figure;
% axes('next','add')
% plot(inputIdx(:,1))
% plot(outIdx(:,1))

%% v slow

% idxLength = size(inputIdx,1);
% outIdx    = false(idxLength,1); % preallocate output
% 
% for n = 1:size(inputIdx,2)
%         
%     nanPositions = find(inputIdx(:,n));     
%     
%     removeidx = NaN(size(nanPositions,1)+1,2);
%     
%     removeidx(:,1) = [1; nanPositions] - extval;
%     removeidx(:,2) = [1; nanPositions] + extval;
%     removeidx(removeidx < 1) = 1;
%     removeidx(removeidx > idxLength) = idxLength;
%     
%     nanidx = false(idxLength,1);
%     
%     for ne = 1:size(removeidx,1)
%         nanidx(removeidx(ne,1):removeidx(ne,2)) = true;
%     end
%     
%     outIdx(:,n) = nanidx;
%     
% end


