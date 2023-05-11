function formatted_string = cell2str(cell_to_format, delimeter, final_delimeter, padding)
% CELL2STR Helper function to convert a cell of values into a string which
% is well formatted for printing.
%   formatted_string = cell2str(cell_to_format, delimeter, final_delimeter) 
%   converts cell_to_format to a string which contains the values of
%   cell_to_format separated by the given delimeter, with a special 
%   final_delimeter between the second-to-last and last elements. There 
%   will be no delimeter placed after the last element. Optionally, you can
%   specify padding to add to either side of each element in cell_to_format.
%   If delimeter is not given, then ', ' will be used. 
%   If final_delimeter is not given, then it will be set to match delimeter.
%   If pad_elements is not given, it will not be used.
%   Regrettably, this implementation does not have good support for the
%   oxford comma when cell_to_format only contains two elements.

    arguments
        cell_to_format cell
        delimeter {mustBeTextScalar} = '\n'
        final_delimeter {mustBeTextScalar} = delimeter
        padding {mustBeTextScalar} = ''
    end

    % FIXME: This naive approach continuously appends new elements to this
    % variable, which makes it change size on every loop iteration.
    formatted_string = '';

    total_num_cell_elements = numel(cell_to_format);
    
    for i = 1:total_num_cell_elements
        
        current_cell_contents = cell_to_format{i};

        % Convert the current cell contents to a char, if necessary, and
        % add padding.
        if (isstring(current_cell_contents) || ischar(current_cell_contents))
            % If the current data is text, simply add padding chars
            cell_contents_char = [padding, char(current_cell_contents), padding];
        elseif (isnumeric(current_cell_contents) || islogical(current_cell_contents))
            % If the current data is numerical or logical, convert it to a
            % string and add padding
            cell_contents_char = [padding, num2str(current_cell_contents), padding];
        elseif iscell(current_cell_contents)
            % FIXME: potentially do a better check to add final_delimeter
            % to the correct location when last element is a cell.
            % If the current data is a cell (potentially with additional
            % nested elements), recursively generate a string. Note that
            % the final delimeter will not be passed to this unzipping.
            cell_contents_char = cell2str(current_cell_contents, delimeter, delimeter, padding);
        else
            % Unsupported data type
            warning('Cell element %d has unsupported datatype %s for converting to string, skipping...', i, class(current_cell_contents));
            continue
        end

        % Add the current cell contents to formatted string
        % The use of horizontal array concatenation as opposed to the
        % built-in strcat(s1,s2,...) function is to preserve trailing
        % whitespaces.
        formatted_string = [formatted_string, cell_contents_char];

        % Determine which delimeter to add between next element
        if i == (total_num_cell_elements - 1)
            % If this is the second-to-last element, add final_delimeter
            delimeter_to_add = final_delimeter;
        elseif i ~= total_num_cell_elements
            % If this is not the last element, add delimeter
            delimeter_to_add = delimeter;
        else
            % If this is the last element, do not add a delemeter
            delimeter_to_add = '';
        end

        % Add the current delimeter to formatted string
        formatted_string = [formatted_string, sprintf(delimeter_to_add)];

    end

end