function idx = getIndices(input)

%
% finds indices for all variables of structure/table
%
% Soraya Dunn 2015
%

try
    % stop varibale name warning
    warning('off','MATLAB:namelengthmaxexceeded');
    
    % extract variable names
    if isstruct(input)
        vars =  fieldnames(input);
    elseif istable(input)
        vars = input.Properties.VariableNames;
    end
    
    % for each variable find unique values and indices for these
    for j = 1 : length(vars)
        
        v = vars{j};
        
        % skip certain varibales
        if iscell(input.(v)(1))
            if~iscellstr(input.(v)(1))
                continue
            end
        end
        if any(strfind(v,'Path'))
            continue
        end
        if any(strfind(v,'idx'))
            continue
        end
  %      if numel(input(1).(v)) == 1         % only index variables with single elements
            try
                 v_unique = unique([input.(v)]);
            catch  % doesn't like it when there are cells within cells 
                continue
            end
            if isstruct(input)
            nV_unq = size(v_unique,2);
            nV_tot = size(input,2);
            else 
            nV_unq = size(v_unique,1);
            nV_tot = size(input,1);
            end

            
%             if nV_unq > (nV_tot/4)       % skip if too many unique values- ie more than half
%                 continue
%             end
            
            for jj = 1 : nV_unq
                
                v_jj = v_unique(jj);
                if iscell(v_jj)
                    v_JJ = v_jj{1};
                elseif isscalar(v_jj)
                    v_JJ = num2str(v_jj);
                end
                
                % fieldname for index = 'is+value'
                fn = ['is' v_JJ];
                
                if strfind(fn, '.')
                    fn = strrep(fn, '.', '');
                end
                if strfind(fn, '-')
                    fn = strrep(fn, '-', '');
                end
                if strfind(fn, ' ')
                    fn = strrep(fn, ' ', '');
                end
                if strfind(fn, '_')
                    fn = strrep(fn, '_', '');
                end
                if strfind(fn, ',')
                    fn = strrep(fn, ',', '');
                end
                if strfind(fn, '/')
                    fn = strrep(fn, '/', '');
                end
                 if strfind(fn, ':')
                    fn = strrep(fn, ':', '');
                end
%                 if numel(fn)>5
%                     fn = fn(1:5);
%                 end
%                 
                if isnumeric(v_jj);
                    idx.(v).(fn) = [input.(v)] == v_jj;
                else
                
                idx.(v).(fn) = strcmp(input.(v), v_JJ);

                end
                    
                
            end
%         else
%             continue    % continue if variable contains vectors
%         end
    end
    
catch err
    err
    keyboard
end



end