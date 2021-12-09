function stop_table_warnings

% Suppress warnings about default row contents
warning('off', 'MATLAB:table:RowsAddedExistingVars');
warning('off','MATLAB:table:RowsAddedNewVars');
