function pc = percent_high(logIdx)

%
% returns percentage of logical index that is ones
%

pc = sum(logIdx)/length(logIdx) * 100;