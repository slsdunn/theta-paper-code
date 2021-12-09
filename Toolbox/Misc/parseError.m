function parseError(err)

disp(err.message)

% Get stack
s = err.stack;

% For each line
for i = 1 : numel(s)
    
    % Print file and line
    [~, f] = fileparts(s(i).file);
    x = s(i).line;
    
    fprintf('Line %d\t%s\n', x, f)
end