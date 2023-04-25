classdef TLEHandler < handle
    % TLEHANDLER Handler for Two-Line-Element (TLE) sets, which define properties
    % of a satellite.
    %   Detailed explanation goes here
    
    properties
        TLEHandles TLE
        % TLEFactory TLEFactory = TLEFactory()  % rip in peace
        AutoGenerateChecksums = false  % FIXME: should be initialized based on GUI checkbox initial value, or vice-versa
        IgnoreChecksums = false  % FIXME: same as autogeneratechecksums
        LastSelectedTLEIndex(1,1) double {mustBeInteger} = 0  % FIXME: this shouldn't be necessary, but is simple
    end

    properties(Constant)
        DefaultOutputFileExtension = '.tle'  % FIXME: these variables probably don't need to exist
        DefaultOutputEncodingFormat = 'UTF-8'
        AllowedOutputEncodingFormats = {'UTF-8', 'US-ASCII'}

        DefaultSatelliteName = ''
        DefaultSatelliteCatalogNumber = 0
        DefaultClassification = 'U'
        DefaultLaunchYear = []
        DefaultLaunchNumber = []
        DefaultLaunchPiece = ''
        DefaultFirstDerivOfMeanMotion = 0
        DefaultSecondDerivOfMeanMotion = 0
        DefaultBStar = 0
        DefaultEphemerisType = '0'
        DefaultElementSetNumber = 0
        DefaultRevolutionAtEpoch = 0
        DefaultChecksum = 0

        % FIXME: a less hard-coded way to do this?
        DefaultTableColumns = { ...
            'ID', ...
            'Name', ...
            'Catalog Number', ...
            'Mean Motion (rev/day)', ...
            'Semimajor Axis (km)', ...
            'Inclination (deg)', ...
            'RAAN (deg)', ...
            'Eccentricity', ...
            'Arg of Perigee (deg)', ...
            'Mean Anomaly (deg)', ...
            'True Anomaly (deg)', ...
            'B-Star (1/[r_Earth])', ...
            'Epoch (UTC)', ...
            'TLE Line 1', ...
            'TLE Line 2'
            }
    end
    
    methods

        function addTLE(obj, tle_object)
            % See if we should re-generate the checksum
            if obj.AutoGenerateChecksums
                tle_object = tle_object.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
            end

            % Adds TLEs to TLE list
            for i = 1:size(tle_object, 1)
                obj.TLEHandles(end + 1) = tle_object(i);
            end
        end

        % function addTLEFromFile(obj, file_name, ignore_checksum, TLE_to_load)
        %     % Adds TLE from file 
        %     TLEs = obj.TLEFactory.createTLEFromFile(file_name, ignore_checksum, TLE_to_load);
        % 
        %     % Only add TLE if the TLE list is not empty
        %     if ~isempty(TLEs)
        %         obj.addTLE(TLEs)
        %     end
        % end
        % 
        % function addTLEFromURL(obj, url_string, ignore_checksum, sat_num_or_name)
        %     % Adds TLE from URL
        %     TLE_to_add = obj.TLEFactory.createTLEFromURL(url_string, ignore_checksum, sat_num_or_name);
        % 
        %     % Only add TLE if the TLE list is not empty
        %     if ~isempty(TLE_to_add)
        %         obj.addTLE(TLE_to_add);
        %     end
        % end

        function [table_data, warning_rows_to_highlight, function_events] = generateSatellitesTableData(obj)
            % Initialize outputs
            function_events = ConsoleEvent.empty;
            table_data = table();
            warning_rows_to_highlight = false(1,0);

            try

                % Initialize table columns
                table_column_names = obj.DefaultTableColumns;

                % Initialize loop variables
                total_num_TLEs = length(obj.TLEHandles);
                
                id_column_data = cell(total_num_TLEs, 1);
                name_column_data = cell(total_num_TLEs, 1);
                catalog_num_column_data = cell(total_num_TLEs, 1);
                mean_motion_column_data = cell(total_num_TLEs, 1);
                semimajor_axis_column_data = cell(total_num_TLEs, 1);
                inclination_column_data = cell(total_num_TLEs, 1);
                raan_column_data = cell(total_num_TLEs, 1);
                eccentricity_column_data = cell(total_num_TLEs, 1);
                arg_of_perigee_column_data = cell(total_num_TLEs, 1);
                mean_anomaly_column_data = cell(total_num_TLEs, 1);
                true_anomaly_column_data = cell(total_num_TLEs, 1);
                b_star_column_data = cell(total_num_TLEs, 1);
                epoch_column_data = cell(total_num_TLEs, 1);
                TLE_line_2_column_data = cell(total_num_TLEs, 1);
                TLE_line_1_column_data = cell(total_num_TLEs, 1);
                
                % Loop through TLEs to extract data
                warning_rows_to_highlight = false(1, total_num_TLEs);
                % error_rows_to_highlight = false(1, total_num_TLEs);
                for i = 1:total_num_TLEs

                    current_TLE = obj.TLEHandles(i);
                    
                    id_column_data{i} = i;
                    name_column_data{i} = current_TLE.SatelliteName;
                    catalog_num_column_data{i} = current_TLE.CatalogNumber;
                    mean_motion_column_data{i} = current_TLE.MeanMotion;
                    semimajor_axis_column_data{i} = current_TLE.SemiMajorAxis / 1000;  % note conversion from [m] to [km]
                    inclination_column_data{i} = current_TLE.Inclination;
                    raan_column_data{i} = current_TLE.RAAN;
                    eccentricity_column_data{i} = current_TLE.Eccentricity;
                    arg_of_perigee_column_data{i} = current_TLE.ArgumentOfPeriapsis;
                    mean_anomaly_column_data{i} = current_TLE.MeanAnomaly;
                    true_anomaly_column_data{i} = current_TLE.TrueAnomaly;
                    b_star_column_data{i} = current_TLE.BStar;
                    epoch_column_data{i} = char(current_TLE.Epoch);
                    TLE_line_1_column_data{i} = current_TLE.TLELine1;
                    TLE_line_2_column_data{i} = current_TLE.TLELine2;

                    if ~obj.IgnoreChecksums
                        checksums_valid = current_TLE.Checksum1Valid && current_TLE.Checksum2Valid;
                    else
                        checksums_valid = true;
                    end
                    if ~checksums_valid
                        warning_rows_to_highlight(i) = true;
                    end

                end

                % Build data cell
                % Order must match default column ordering!
                % { ...
                %     'ID', ...
                %     'Name', ...
                %     'Catalog Number', ...
                %     'Mean Motion (rev/day)', ...
                %     'Semimajor Axis (km)', ...
                %     'Inclination (deg)', ...
                %     'RAAN (deg)', ...
                %     'Eccentricity', ...
                %     'Arg of Perigee (deg)', ...
                %     'Mean Anomaly (deg)', ...
                %     'True Anomaly (deg)', ...
                %     'B-Star (1/[r_earth])', ...
                %     'Epoch', ...
                %     'TLE Line 1', ...
                %     'TLE Line 2'
                % }
                table_data_cell = [ ...
                    id_column_data, ...
                    name_column_data, ...
                    catalog_num_column_data, ...
                    mean_motion_column_data, ...
                    semimajor_axis_column_data, ...
                    inclination_column_data, ...
                    raan_column_data, ...
                    eccentricity_column_data, ...
                    arg_of_perigee_column_data, ...
                    mean_anomaly_column_data, ...
                    true_anomaly_column_data, ...
                    b_star_column_data, ...
                    epoch_column_data, ...
                    TLE_line_1_column_data, ...
                    TLE_line_2_column_data];

                warning off  % FIXME: only disable specific type of warning
                table_data.Variables = table_data_cell;
                warning on
                table_data.Properties.VariableNames = table_column_names;

                % TODO: some more dynamic version of this, with
                % verification of input/output. Preferrably without
                % directly looking up the current state of the table.
                warning_rows_to_highlight = find(warning_rows_to_highlight);
                
                event_message = sprintf('Generated satellites table data from %d stored TLEs.', ...
                    total_num_TLEs);
                new_events = ConsoleEvent(event_message);
                function_events = [function_events, new_events];

            catch e

                event_message = sprintf('Unable to generate table using stored TLEs. Returning empty table.');
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                return

            end

        end

        function function_events = addTLEsFromKeplerianElements(obj, ...
                satellite_name, epoch_year, epoch_day, semimajor_axis, ...
                eccentricity, inclination, raan, arg_of_periapsis, true_anomaly)

            function_events = ConsoleEvent.empty;

            % Preprocess input
            try

                % Set some empty default values to pass to TLE constructor
                if isempty(satellite_name)
                    satellite_name = obj.DefaultSatelliteName;
                end
                cat_num = obj.DefaultSatelliteCatalogNumber;
                classification = obj.DefaultClassification;
                intl_designator_year = obj.DefaultLaunchYear;
                intl_designator_launch_num = obj.DefaultLaunchNumber;
                intl_designator_piece = obj.DefaultLaunchPiece;
                first_deriv_of_mean_motion = obj.DefaultFirstDerivOfMeanMotion;
                second_deriv_of_mean_motion = obj.DefaultSecondDerivOfMeanMotion;
                b_star = obj.DefaultBStar;
                ephemeris_type = obj.DefaultEphemerisType;
                element_set_num = obj.DefaultElementSetNumber;
                checksum_1 = obj.DefaultChecksum;
                rev_num_at_epoch = obj.DefaultRevolutionAtEpoch;
                checksum_2 = obj.DefaultChecksum;

                % Convert Keplerian elements to SGP4 elements
                % TODO: cause fuss if this is more than 100? 
                % This gives a limit to semimajor axis (which is still smaller than r_earth, unfortunately)
                mean_motion = semimajorAxisToMeanMotion(semimajor_axis);  
                mean_anomaly = trueAnomalyToMeanAnomalyd(true_anomaly, eccentricity);

            catch e
                % FIXME: output elements here?
                event_message = sprintf('Unable to initialize Keplerian elements. Skipping adding satellite.');
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                return
            end

            % Create TLE object
            try

                new_TLE = TLE(satellite_name, cat_num, classification, ...
                    intl_designator_year, intl_designator_launch_num, ...
                    intl_designator_piece, epoch_year, epoch_day, ...
                    first_deriv_of_mean_motion, second_deriv_of_mean_motion, ...
                    b_star, ephemeris_type, element_set_num, checksum_1, ...
                    inclination, raan, eccentricity, arg_of_periapsis, ...
                    mean_anomaly, mean_motion, rev_num_at_epoch, checksum_2);

            catch e
                % FIXME: output elements here?
                event_message = sprintf('Unable to create TLE from Keplerian elements. Skipping adding satellite.');
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                return

            end

            % Auto-generate checksums
            new_TLE = new_TLE.generateTLELinesFromStoredVariables(true);

            obj.addTLE(new_TLE);

            % FIXME: output elements here?
            event_message = sprintf('Created satellite from Keplerian elements.');
            new_events = ConsoleEvent(event_message);
            function_events = [function_events, new_events];
            

        end

        function function_events = addTLEsFromSGP4Elements(obj, ...
                satellite_name, epoch_year, epoch_day, mean_motion, ...
                eccentricity, inclination, raan, arg_of_periapsis, ...
                mean_anomaly, b_star)

            function_events = ConsoleEvent.empty;

            % Preprocess input
            try

                % Set some empty default values to pass to TLE constructor
                if isempty(satellite_name)
                    satellite_name = obj.DefaultSatelliteName;
                end
                cat_num = obj.DefaultSatelliteCatalogNumber;
                classification = obj.DefaultClassification;
                intl_designator_year = obj.DefaultLaunchYear;
                intl_designator_launch_num = obj.DefaultLaunchNumber;
                intl_designator_piece = obj.DefaultLaunchPiece;
                first_deriv_of_mean_motion = obj.DefaultFirstDerivOfMeanMotion;
                second_deriv_of_mean_motion = obj.DefaultSecondDerivOfMeanMotion;
                ephemeris_type = obj.DefaultEphemerisType;
                element_set_num = obj.DefaultElementSetNumber;
                checksum_1 = obj.DefaultChecksum;
                rev_num_at_epoch = obj.DefaultRevolutionAtEpoch;
                checksum_2 = obj.DefaultChecksum;

            catch e
                % FIXME: output elements here?
                event_message = sprintf('Unable to initialize SGP4 elements. Skipping adding satellite.');
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                return
            end

            % Create TLE object
            try

                new_TLE = TLE(satellite_name, cat_num, classification, ...
                    intl_designator_year, intl_designator_launch_num, ...
                    intl_designator_piece, epoch_year, epoch_day, ...
                    first_deriv_of_mean_motion, second_deriv_of_mean_motion, ...
                    b_star, ephemeris_type, element_set_num, checksum_1, ...
                    inclination, raan, eccentricity, arg_of_periapsis, ...
                    mean_anomaly, mean_motion, rev_num_at_epoch, checksum_2);

            catch e
                % FIXME: output elements here?
                event_message = sprintf('Unable to create TLE from SGP4 elements. Skipping adding satellite.');
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                return

            end

            % Auto-generate checksums
            new_TLE = new_TLE.generateTLELinesFromStoredVariables(true);

            obj.addTLE(new_TLE);

            % FIXME: output elements here?
            event_message = sprintf('Created satellite from SGP4 elements.');
            new_events = ConsoleEvent(event_message);
            function_events = [function_events, new_events];
            
        end

        function function_events = addTLEsFromText(obj, raw_text)
            
            % Initialize output
            % TODO: prellocate this and append new events properly
            function_events = ConsoleEvent.empty;

            try            
                % Preprocess input

                % Trim input to facilitate search
                raw_text = strip(raw_text);

                % Remove empty lines
                total_num_lines = length(raw_text);
                line_is_empty = false(1, total_num_lines);
                for i = 1:total_num_lines
                    current_line = raw_text{i};
                    if isempty(current_line)
                        line_is_empty(i) = true;
                    end
                end
                raw_text(line_is_empty) = [];

                % Number of TLE lines
                total_num_lines = length(raw_text);
    
                if total_num_lines == 0
                    event_message = 'TLE text is empty. No stallites added.';
                    event_error_code = StatusCode.Warning;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

                % Loop through lines
                num_TLEs_found = 0;
                line_has_been_parsed = false(1, total_num_lines);
    
                % Parse through every line, allocates lines
                for i = 1:(total_num_lines-1)
    
                    if line_has_been_parsed(i)
                        continue
                    end
    
                    % Get line
                    current_line = raw_text{i};
                    current_line_length = length(current_line);
    
                    if current_line_length < 2
                        continue
                    end
                    % If current line is 2 characters or longer, we'll
                    % check to see if it begins with '1 ', suggesting it's
                    % TLE data
                    current_line_is_TLE = strcmp(current_line(1:2), '1 ');
                    if ~current_line_is_TLE
                        continue
                    end
    
                    % If this is a TLE line, try to parse it and the lext
                    % line
                    if current_line_is_TLE
                        % First we have to check that there are two lines
                        % left in the file to return.
                        num_lines_left_in_file = total_num_lines - i + 1;  % +1 for including the current line
                        enough_lines_left = num_lines_left_in_file >= 2;
                        if ~enough_lines_left
                            continue
                        end
                        tle_line_1 = raw_text{i};
                        tle_line_2 = raw_text{i+1};
                    end

                    % See if there's a title on the previous line
                    prev_line_is_title = false;
                    if i > 1
                        prev_line = raw_text{i-1};
                        prev_line_length = length(prev_line);
                        if prev_line_length < 2
                            % If the previous line is less than 2
                            % characters long (but not empty), we can
                            % safely assume it's a title
                            prev_line_is_title = true;
                        else
                            % Wonky branching logic to not access OOB line
                            % characters
                            prev_line_is_title = ~strcmp(prev_line(1:2), '2 ');
                        end
                    end
                    if prev_line_is_title
                        satellite_name = prev_line;
                    else
                        satellite_name = '';
                    end

    
                    % Attempt to parse and add TLE lines
                    new_events = obj.createTLEFromTLELines(tle_line_1, tle_line_2, satellite_name);
                    function_events = [function_events, new_events];
                    if new_events(end).EventStatusCode == StatusCode.Success
                        num_TLEs_found = num_TLEs_found + 1;
                        if prev_line_is_title
                            line_has_been_parsed(i-1:i+1) = true;
                        else
                            line_has_been_parsed(i:i+1) = true;
                        end
                    end
    
                end

                event_message = sprintf('Found %d valid TLEs in text.', num_TLEs_found);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = 'Invalid TLE text. No stallites added.';
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                return

            end

        end

        function function_events = createTLEFromTLELines(obj, line_1, line_2, satellite_name)
            if nargin == 2
                satellite_name = '';
            end

            function_events = ConsoleEvent.empty;

            try
                [cat_num_1, classification, intl_designator_year, ...
                    intl_designator_launch_num, intl_designator_piece, ...
                    epoch_year, epoch_day, first_deriv_of_mean_motion, ...
                    second_deriv_of_mean_motion, b_star, ephemeris_type, ...
                    element_set_num, checksum_1, line_1_events] = ...
                    obj.parseTLELine1(line_1);

                num_new_events = length(line_1_events);
                function_events(end+1:end+num_new_events) = line_1_events;

                if function_events(end).EventStatusCode == StatusCode.Error

                    event_message = sprintf('Unable to parse TLE line 1 "%s", skipping adding TLE.', line_1);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return

                end

            catch e

                event_message = sprintf('Unable to parse TLE line 1 "%s", skipping adding TLE.', line_1);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                return

            end

            try

                [cat_num_2, inclination, RAAN, eccentricity, ... 
                    arg_of_periapsis, mean_anomaly, mean_motion, ...
                    rev_num_at_epoch, checksum_2, line_2_events] = ...
                    obj.parseTLELine2(line_2);

                num_new_events = length(line_2_events);
                function_events(end+1:end+num_new_events) = line_2_events;

                if function_events(end).EventStatusCode == StatusCode.Error

                    event_message = sprintf('Unable to parse TLE line 2 "%s", skipping adding TLE.', line_1);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return

                end

            catch e

                event_message = sprintf('Unable to parse TLE line 2 "%s", skipping adding TLE.', ...
                    line_2);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                return

            end

            % Check that catalog numbers match
            if ~isequal(cat_num_1, cat_num_2)

                event_message = sprintf('Catalog number from TLE line 1 %d does not match number from line 2 %d. Using value from line 1.', ...
                    cat_num_1, cat_num_2);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            
            end

            % Create TLE object
            try

                new_TLE = TLE(satellite_name, cat_num_1, classification, ...
                    intl_designator_year, intl_designator_launch_num, ...
                    intl_designator_piece, epoch_year, epoch_day, ...
                    first_deriv_of_mean_motion, second_deriv_of_mean_motion, ...
                    b_star, ephemeris_type, element_set_num, checksum_1, ...
                    inclination, RAAN, eccentricity, arg_of_periapsis, ...
                    mean_anomaly, mean_motion, rev_num_at_epoch, checksum_2);

            catch e

                event_message = sprintf('Unable to create TLE from lines\n"%s",\n"%s".\nSkipping adding TLE.', ...
                    line_1, line_2);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                return

            end

            obj.addTLE(new_TLE);

            event_message = sprintf('Created TLE from lines\n"%s",\n"%s".', ...
                line_1, line_2);
            new_events = ConsoleEvent(event_message);
            function_events = [function_events, new_events];

        end

        function [found_TLE_lines, function_events] = findTLE(~, raw_text, search_terms, exact_match_required)
            
            % Find tle based on name or catalog number

            if nargin == 3
                exact_match_required = false;
            end

            % Initialize output
            found_TLE_lines = cell(0);
            function_events = ConsoleEvent.empty;

            % Preprocess input
            try

                % Trim input to facilitate search
                raw_text = strip(raw_text);

            catch e

                event_message = 'Invalid TLE text. No TLEs found.';
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                return

            end

            try

                % Trim input to facilitate search
                search_terms = strip(search_terms);

            catch e

                event_message = 'Invalid search terms for satellite name or number. No TLEs found.';
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                return

            end

            try
                % Loop variables
                total_num_lines = numel(raw_text);
                line_has_TLE_data = false(1, total_num_lines);  % for flagging lines where we found a TLE
                num_TLEs_found = 0;

                % Parse through every TLE and find the right one
                for i = 1:(total_num_lines-1)  % don't bother checking the last line
    
                    % If the current line has already been marked as contianing
                    % a searched TLE, skip checking it
                    if line_has_TLE_data(i)
                        continue
                    end
                    
                    % Get rid of any leading or trailing blanks from current
                    % line
                    current_line = raw_text{i};
                    current_line = strip(current_line);
    
                    % Check to see if the current line contains any of the
                    % search terms
                    line_has_search_term = contains(current_line, search_terms, 'IgnoreCase', true);
                    
                    % If it does, determine if we have matched a name or
                    % catalog number. To simplify the logic a bit here, 
                    % all it checks for is...
                    %   1) whether the line begins with a '1'
                    %   2) whether the line is 69 characters long
                    % If both of those things are true, then this has likely
                    % matched in a TLE line, and we should return only this
                    % line and the next.
                    % If one of those things is false, it's reasonably safe to
                    % assume this has matched on a title line, and we should
                    % return this line and the following two lines.
                    % These returned lines might contain invalid TLE data, but
                    % that's okay. This will be checked later during the TLE
                    % creation itself.
                    if line_has_search_term
                        
                        first_char_is_1 = strcmp(current_line(1), '1');
                        line_is_correct_length = length(current_line) == 69;
    
                        line_is_TLE_data = first_char_is_1 && line_is_correct_length;
                        
                        if line_is_TLE_data

                            % If this is a TLE line, flag this line and the
                            % next line for returning.
                            line_has_TLE_data(i:(i+1)) = true;

                            % Note that we've found another TLE (so this number
                            % doesn't have to be inferred later)
                            num_TLEs_found = num_TLEs_found + 1;

                            % Check if the *previous* line might have been
                            % a title
                            if i == 0
                                % If it's the first line of the file, then no
                                continue
                            end
                            
                            previous_line = strip(raw_text{i-1});
                            prev_line_length = length(previous_line);
                            
                            if prev_line_length == 0
                                % If the previous line is blank, then no
                                continue
                            end

                            if prev_line_length == 1
                                % If the previous line only has one
                                % character, then it's safe to assume it's
                                % a title
                                line_has_TLE_data(i-1) = true;
                            end

                            % If the line is longer, we need to check if
                            % it's TLE data or not.
                            prev_first_char_is_2 = strcmp(previous_line(1), '2');
                            prev_line_is_correct_length = prev_line_length == 69;
                            prev_line_is_TLE_data = prev_first_char_is_2 && prev_line_is_correct_length;
                            if ~prev_line_is_TLE_data
                                % If the previous line isn't TLE data, 
                                % then it's safe to assume it's a title
                                line_has_TLE_data(i-1) = true;
                            end


                        else

                            % If this line is not a TLE line (it's a title
                            % line), flag this line and the next two lines for
                            % returning.
                            % First we have to check that there are two lines
                            % left in the file to return.
                            num_lines_left_in_file = total_num_lines - i + 1;  % +1 for including the current line
                            enough_lines_left = num_lines_left_in_file >= 3;
                            if ~enough_lines_left
                                continue
                            end

                            % If an exact match is required, make sure
                            % that's the case. Note that this is only
                            % checked for titles, if your search term
                            % matched to TLE data (say, catalog number)
                            % then it's automatically assumed that an exact
                            % match was found.
                            if exact_match_required
                                line_matches_exactly = any(strcmpi(search_terms, current_line));
                                if ~line_matches_exactly
                                    continue
                                end
                            end

                            line_has_TLE_data(i:(i+2)) = true;

                            % Note that we've found another TLE (so this number
                            % doesn't have to be inferred later)
                            num_TLEs_found = num_TLEs_found + 1;
                            
                        end
    
                    end
    
                end

                % Assign output with found lines
               found_TLE_lines = raw_text(line_has_TLE_data); 

            catch e

                event_message = sprintf('Unable to parse raw text lines during TLE search. Skipping searching for %s.', cell2str(search_terms, ', ', ' or ', '"'));
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                return

            end


            % If it couldn't find the TLE, return empty cell, else return
            % the found TLE
            no_TLE_lines_found = num_TLEs_found == 0;
            if no_TLE_lines_found
                event_message = sprintf('Unable to find search terms %s in TLE text.', cell2str(search_terms, ', ', ' or ','"'));
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else
                event_message = sprintf('Found %d TLEs matching the search terms %s in TLE text.', num_TLEs_found, cell2str(search_terms, ', ', ' or ','"'));
                new_events = ConsoleEvent(event_message);
                function_events = [function_events, new_events];
            end

        end

        function tle_handles = getTLEByName(obj, tle_name_str, return_all_instances)
            % Find TLE based on name

            % Loop through currently stored TLEs
            total_num_tles = length(obj.TLEHandles);
            tles_to_get = false(1, total_num_tles);
            for i = 1:total_num_tles

                current_TLE_name = obj.TLEHandles(i).SatelliteName;

                % Check to see if name matches
                if strcmpi(tle_name_str, current_TLE_name)  % not case sensitive
                    
                    % Flag TLE for returning
                    tles_to_get(i) = true;

                    % Check to see if return all instances flag wants us to
                    % stop here or not
                    if ~return_all_instances
                        break;
                    end

                end
                
            end

            % Return flagged TLEs
            tle_handles = obj.TLEHandles(tles_to_get);

        end

        function removeTLE(obj, tle_handle, TLE_index)
            % Delete from TLE list
            obj.TLEHandles(TLE_index) = [];

            % Message
            warning("%s's TLE has been deleted", strtrim(tle_handle.SatelliteName))
        end

        % SEBASTIAN'S COMMENT: I have not touched/used this funct, should we keep it?
        function removeTLEByName(obj, tle_name_str, delete_all_instances)
            % Note: this function can't be used if the TLE doesn't have a
            % name defined, there may be a better way to do this
            
            % Loop through currently stored TLEs
            total_num_tles = length(obj.TLEHandles);
            tles_to_delete = false(1, total_num_tles);
            for i = 1:total_num_tles

                current_TLE_name = obj.TLEHandles(i).SatelliteName;

                % Check to see if name matches
                if strcmpi(tle_name_str, current_TLE_name)  % not case sensitive
                    
                    % Flag TLE for deletion
                    tles_to_delete(i) = true;

                    % Check to see if delete all instances flag wants us to
                    % stop here or not
                    if ~delete_all_instances
                        break;
                    end

                end
                
            end

            % Delete flagged TLEs
            % FIXME: Not sure what the "best practice" way to do this is...
%             obj.TLE_handles(tles_to_delete) = [];
            tle_handles_to_delete = obj.TLEHandles(tles_to_delete);
            num_tles_to_delete = length(tle_handles_to_delete);
            for i = 1:num_tles_to_delete
                obj.removeTLE(tle_handles_to_delete(i));
            end

        end

        function [catalog_num, classification, intl_designator_year, ...
                    intl_designator_launch_num, intl_designator_piece, ...
                    epoch_year, epoch_day, first_deriv_of_mean_motion, ...
                    second_deriv_of_mean_motion, b_star, ephemeris_type, ...
                    element_set_num, checksum, function_events] = ...
                    parseTLELine1(obj, line_1_text)

            % Initialize outputs
            catalog_num = []; 
            classification = ''; 
            intl_designator_year = [];
            intl_designator_launch_num = [];
            intl_designator_piece = [];
            epoch_year = [];
            epoch_day = [];
            first_deriv_of_mean_motion = [];
            second_deriv_of_mean_motion = [];
            b_star = [];
            ephemeris_type = '';
            element_set_num = [];
            checksum = [];
            function_events = ConsoleEvent.empty;

            % Check for required length
            TLE_length = 69;
            TLE_input_length = strlength(line_1_text);

            if TLE_input_length ~= TLE_length
                event_message = sprintf('TLE line 1 must be %d characters in length, not %d.', ...
                    TLE_length, TLE_input_length);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
                return
            end
            
            % Make sure the first character is 1
            first_character = str2double(line_1_text(1));
            if first_character ~= 1
                event_message = sprintf('TLE line 1 must start with 1, not %s.', ...
                    first_character);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
                return
            end

            % Check for required empty columns
            empty_space_columns = [2, 9, 18, 33, 44, 53, 62, 64];
            num_empty_spaces = length(empty_space_columns);

            for i = 1:num_empty_spaces
                current_col = empty_space_columns(i);
                input_char = line_1_text(current_col);
                if ~isspace(input_char)
                    event_message = sprintf('Column %d in TLE line 1 must be empty, not %s.', ...
                        current_col, input_char);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
            end
            
            % Check for satellite catalog number
            sat_num_columns = 3:7;
            % If catalog number is completely empty, assign default value
            input_cat_num_str = line_1_text(sat_num_columns);
            if all(isstrprop(input_cat_num_str, 'wspace'))
                default_value = obj.DefaultSatelliteCatalogNumber;
                catalog_num = default_value;
                event_message = sprintf('Satellite catalog number (column %d through %d) in TLE line 1 not given, assigning default value of %d.', ...
                    sat_num_columns(1), sat_num_columns(end), default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else
                % If it's not empty, attempt to convert the value to a
                % number
                catalog_num = str2double(input_cat_num_str);
                input_invalid = isnan(catalog_num) || ...
                    isinf(catalog_num) || ...
                    ~isreal(catalog_num) || ...
                    mod(catalog_num, 1) ~= 0 || ...
                    catalog_num < 0;

                if input_invalid
                    event_message = sprintf('Satellite catalog number (column %d through %d) in TLE line 1 %s is invalid.', ...
                        sat_num_columns(1), sat_num_columns(end), input_cat_num_str);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
            end

            % Check for classification
            class_column = 8;
            classification = line_1_text(class_column);
            if isstrprop(classification, 'wspace')
                default_value = obj.DefaultClassification;
                classification = default_value;
                event_message = sprintf('Satellite class (column %d) in TLE line 1 not given, assigning default value of %s.', ...
                    class_column, default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else
                input_invalid = ~ismember(classification, {'U', 'C', 'S'});
   
                if input_invalid
                    event_message = sprintf('Satellite class (column %d) in TLE line 1 is invalid. Must be "U", "C", or "S", not "%s".', ...
                        class_column, classification);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
            end

            % Check for international designators
            intl_designator_yr_columns = 10:11;
            intl_designator_num_columns = 12:14;
            intl_designator_piece_columns = 15:17;
            input_intl_designator_yr = line_1_text(intl_designator_yr_columns);
            input_intl_designator_num = line_1_text(intl_designator_num_columns);
            input_intl_designator_piece = line_1_text(intl_designator_piece_columns);

            % Check existance of fields
            intl_designator_yr_exists = ~all(isstrprop(input_intl_designator_yr, 'wspace'));
            intl_designator_num_exists = ~all(isstrprop(input_intl_designator_num, 'wspace'));
            intl_designator_piece_exists = ~all(isstrprop(input_intl_designator_piece, 'wspace'));

            % Manage bad inputs
            wrong_input_yr = any(~isstrprop(input_intl_designator_yr, "digit"));
            wrong_input_num = any(~isstrprop(input_intl_designator_num, "digit"));
            wrong_input_piece = any(~isstrprop(input_intl_designator_piece, "alpha") & ...
                ~isstrprop(input_intl_designator_piece, "wspace")) || ...
                all(isstrprop(input_intl_designator_piece, "wspace"));

            % If one exists, the others cannot be empty
            if intl_designator_yr_exists || intl_designator_num_exists || intl_designator_piece_exists
                if wrong_input_yr
                    event_message = sprintf('Launch year designator (column %d through %d) in TLE line 1 is invalid. Must contain numerical values, not %s.', ...
                        intl_designator_yr_columns(1), intl_designator_yr_columns(end), input_intl_designator_yr);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
                if wrong_input_num
                    event_message = sprintf('Launch number designator (column %d through %d) in TLE line 1 is invalid. Must contain numerical values, not %s.', ...
                        intl_designator_num_columns(1), intl_designator_num_columns(end), input_intl_designator_num);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
                if wrong_input_piece
                    event_message = sprintf('Launch piece designator (column %d through %d) in TLE line 1 is invalid. Must contain at least one letter followed by spaces, not %s.', ...
                        intl_designator_piece_columns(1), intl_designator_piece_columns(end), input_intl_designator_piece);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

                % If no errors, assign values
                intl_designator_year = str2double(input_intl_designator_yr);  % FIXME: convert this to an actual year, like epoch??
                intl_designator_launch_num = str2double(input_intl_designator_num);
                intl_designator_piece = strip(input_intl_designator_piece);
            else
                % If all fields were blank, assign default values
                default_designator_yr = obj.DefaultLaunchYear;
                default_designator_num = obj.DefaultLaunchNumber;
                default_designator_piece = obj.DefaultLaunchPiece;
                intl_designator_year = default_designator_yr;
                intl_designator_launch_num = default_designator_num;
                intl_designator_piece = default_designator_piece;
                event_message = sprintf('International designators (column %d through %d) in TLE line 1 not given, assigning default values of "%d", "%d", and "%s" for launch year, number, and piece, respectively.', ...
                    intl_designator_yr_columns(1), intl_designator_piece_columns(end), default_designator_yr, default_designator_num, default_designator_piece);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            end

            % Check for Epoch entries
            epoch_yr_columns = 19:20;
            epoch_day_columns = 21:32;
            epoch_day_decimal_column = 24;
            input_epoch_yr = line_1_text(epoch_yr_columns);
            input_epoch_day = line_1_text(epoch_day_columns);
            input_epoch_day_decimal = line_1_text(epoch_day_decimal_column);

            % Manage bad inputs
            epoch_year = str2double(input_epoch_yr);
            wrong_epoch_yr = isnan(epoch_year) || ...
                    isinf(epoch_year) || ...
                    ~isreal(epoch_year) || ...
                    mod(epoch_year, 1) ~= 0 || ...
                    epoch_year < 0;
            epoch_day = str2double(input_epoch_day);
            wrong_input_epoch_day = isnan(epoch_day) || ...
                    isinf(epoch_day) || ...
                    ~isreal(epoch_day) || ...
                    epoch_day < 0;
            wrong_input_decimal = ~ismember(input_epoch_day_decimal, '.');
            
            % Convert epoch year to 1957 - 2056
            if epoch_year <= 56
                epoch_year = epoch_year + 2000;
            elseif epoch_year <=  99
                epoch_year = epoch_year + 1900;
            else
                wrong_epoch_yr = true;
            end

            if wrong_epoch_yr
                event_message = sprintf('Epoch year (column %d through %d) in TLE line 1 is invalid. Must contain positive numerical values, not %s.', ...
                    epoch_yr_columns(1), epoch_yr_columns(end), input_epoch_yr);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
                return
            end
            if wrong_input_epoch_day
                event_message = sprintf('Epoch day (column %d through %d) in TLE line 1 is invalid. Must contain positive numerical values, not %s.', ...
                    epoch_day_columns(1), epoch_day_columns(end), input_epoch_day);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
                return
            end
            if wrong_input_decimal
                event_message = sprintf('Epoch day decimal point (column %d) in TLE line 1 is invalid. Must contain ".", not "%s".', ...
                    epoch_day_decimal_column, input_epoch_day_decimal);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
                return
            end

            % Check for first derivative of mean motion
            first_derivative_columns = 34:43;
            first_derivative_decimal_column = 35;            
            input_first_deriv = line_1_text(first_derivative_columns);
            input_first_deriv_decimal = line_1_text(first_derivative_decimal_column);

            if all(isstrprop(input_first_deriv, 'wspace'))
                default_value = obj.DefaultFirstDerivOfMeanMotion;
                first_deriv_of_mean_motion = default_value;
                event_message = sprintf('First derivative of mean motion (column %d to %d) in TLE line 1 not given, assigning default value of %f.', ...
                    first_derivative_columns(1), first_derivative_columns(end), default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else
            
                % Managed bad inputs
                first_deriv_of_mean_motion = str2double(input_first_deriv);
                wrong_input_first_d =  isnan(first_deriv_of_mean_motion) || ...
                    isinf(first_deriv_of_mean_motion) || ...
                    ~isreal(first_deriv_of_mean_motion);
                wrong_input_decimal = ~ismember(input_first_deriv_decimal, '.');
    
                if wrong_input_first_d
                    event_message = sprintf('First derivative of mean motion (column %d to %d) in TLE line 1 is invalid. Must contian numerical values, not %s.', ...
                        first_derivative_columns(1), first_derivative_columns(end), input_first_deriv);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
                if wrong_input_decimal
                    event_message = sprintf('First derivative of mean motion decimal point (column %d) in TLE line 1 is invalid. Must contian ".", not "%s".', ...
                        first_derivative_decimal_column, input_first_deriv_decimal);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

            end

            % Check for second derivative of mean motion
            second_derivative_columns = 45:52;
            second_derivative_exponent_sign_column = 51;
            input_second_deriv = line_1_text(second_derivative_columns);
            input_second_deriv_exponent_sign = line_1_text(second_derivative_exponent_sign_column);

            if all(isstrprop(input_second_deriv, 'wspace'))
                default_value = obj.DefaultSecondDerivOfMeanMotion;
                second_deriv_of_mean_motion = default_value;
                event_message = sprintf('Second derivative of mean motion (column %d to %d) in TLE line 1 not given, assigning default value of %f.', ...
                    second_derivative_columns(1), second_derivative_columns(end), default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else
            
                % Managed bad inputs, for exponent sign first
                wrong_input_exponent = ~ismember(input_second_deriv_exponent_sign, {'+', '-'});
                if wrong_input_exponent
                    event_message = sprintf('Second derivative of mean motion exponent sign (column %d) in TLE line 1 is invalid. Must contian "+" or "-", not "%s".', ...
                        second_derivative_exponent_sign_column, input_second_deriv_exponent_sign);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

                % Now that we've verified exponent sign, manually insert
                % 'e' character into string before converting to a double
                exponent_char = 'e';
                input_second_deriv_with_e = [line_1_text(second_derivative_columns(1):(second_derivative_exponent_sign_column-1)), ...
                    exponent_char, line_1_text(second_derivative_exponent_sign_column:second_derivative_columns(end))];
                second_deriv_of_mean_motion = str2double(input_second_deriv_with_e);
                wrong_input_second_d =  isnan(second_deriv_of_mean_motion) || ...
                    isinf(second_deriv_of_mean_motion) || ...
                    ~isreal(second_deriv_of_mean_motion);
    
                if wrong_input_second_d
                    event_message = sprintf('Second derivative of mean motion (column %d to %d) in TLE line 1 is invalid. Must contian numerical values in the form of scientific notation ("e" is implied), not %s.', ...
                        second_derivative_columns(1), second_derivative_columns(end), input_second_deriv);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

            end

            % Check for Drag Term
            drag_term_columns = 54:61;
            drag_term_exponent_sign_column = 60;
            input_drag_term = line_1_text(drag_term_columns);
            input_drag_term_exponent_sign = line_1_text(drag_term_exponent_sign_column);

            if all(isstrprop(input_drag_term, 'wspace'))
                default_value = obj.DefaultBStar;
                b_star = default_value;
                event_message = sprintf('Ballistic coefficient B* (column %d to %d) in TLE line 1 not given, assigning default value of %f.', ...
                    drag_term_columns(1), drag_term_columns(end), default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else
            
                % Managed bad inputs, for exponent sign first
                wrong_input_exponent = ~ismember(input_drag_term_exponent_sign, {'+', '-'});
                if wrong_input_exponent
                    event_message = sprintf('Ballistic coefficient B* exponent sign (column %d) in TLE line 1 is invalid. Must contian "+" or "-", not "%s".', ...
                        drag_term_exponent_sign_column, input_drag_term_exponent_sign);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

                % Now that we've verified exponent sign, manually insert
                % 'e' character into string before converting to a double
                % plus a '.' character at beginning
                exponent_char = 'e';
                decimal_char = '.';
                input_drag_term_with_e = [line_1_text(drag_term_columns(1)), decimal_char, ...
                    line_1_text(drag_term_columns(2):(drag_term_exponent_sign_column-1)), ...
                    exponent_char, line_1_text(drag_term_exponent_sign_column:drag_term_columns(end))];
                b_star = str2double(input_drag_term_with_e);
                wrong_drag_term =  isnan(b_star) || ...
                    isinf(b_star) || ...
                    ~isreal(b_star);
    
                if wrong_drag_term
                    event_message = sprintf('Ballistic coefficient B* (column %d to %d) in TLE line 1 is invalid. Must contian numerical values in the form of scientific notation ("e" is implied), not %s.', ...
                        drag_term_columns(1), drag_term_columns(end), input_drag_term);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

            end

            % Check for Ephemeris Type
            ephemeris_type_column = 63;
            input_ephemeris_type = line_1_text(ephemeris_type_column);

            if isstrprop(input_ephemeris_type, 'wspace')
                default_value = obj.DefaultEphemerisType;
                b_star = default_value;
                event_message = sprintf('Ephemeris (column %d) in TLE line 1 not given, assigning default value of %s.', ...
                    ephemeris_type_column, default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else
                ephemeris_type = input_ephemeris_type;
            end

            % Since ephemeris type is used for internal logging only, we
            % allow them to put any character here. Despite this, this
            % should always be 0 when the TLE is issued from a conventional
            % source.
            % % Manage bad inputs
            % wrong_input_ephemeris = str2double(line(ephemeris_type_column)) ~= 0;
            % 
            % if wrong_input_ephemeris
            %     warning("The ephemeris type must be 0. Column 63, Line 1.")
            %     warning("Unable to load the TLE with Line 1: '%s", line)
            %     is_valid = false;
            %     return
            % end

            % Check for Element Set Number
            element_set_num_columns = 65:68;
            input_element_set_num = line_1_text(element_set_num_columns);

            if all(isstrprop(input_element_set_num, 'wspace'))
                default_value = obj.DefaultElementSetNumber;
                element_set_num = default_value;
                event_message = sprintf('Element set number (column %d through %d) in TLE line 1 not given, assigning default value of %d.', ...
                    element_set_num_columns(1), element_set_num_columns(end), default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else

                % If it's not empty, attempt to convert the value to a
                % number
                element_set_num = str2double(input_element_set_num);
                input_invalid = isnan(element_set_num) || ...
                    isinf(element_set_num) || ...
                    ~isreal(element_set_num) || ...
                    mod(element_set_num, 1) ~= 0 || ...
                    element_set_num < 0;

                if input_invalid
                    event_message = sprintf('Element number (column %d through %d) in TLE line 1 %s is invalid.', ...
                        element_set_num_columns(1), element_set_num_columns(end), input_element_set_num);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
            end

            % Check for checksum
            checksum_column = 69;
            input_checksum = line_1_text(checksum_column);
            checksum = str2double(input_checksum);

            % Verify extracted checksum
            input_invalid = isnan(input_checksum) || ...
                isinf(input_checksum) || ...
                ~isreal(input_checksum) || ...
                mod(input_checksum, 1) ~= 0 || ...
                input_checksum < 0;

            if input_invalid
                default_value = 0;
                checksum = 0;
                event_message = sprintf('Checksum (column %d) in TLE line 1 is invalid. Must contain numerical data, not %s. Setting to default value of %d.', ...
                    checksum_column, input_element_set_num, default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            end

            % Send final message to say we have successfully parsed line
            % one
            event_message = sprintf('Successfully parsed TLE line 1 "%s".', line_1_text);
            new_events = ConsoleEvent(event_message);
            function_events = [function_events, new_events];

        end

        function [catalog_num, inclination, RAAN, eccentricity, ... 
                    arg_of_periapsis, mean_anomaly, mean_motion, ...
                    rev_num_at_epoch, checksum, function_events] = ...
                    parseTLELine2(obj, line_2_text)

            % Initialize outputs
            catalog_num = []; 
            inclination = [];
            RAAN = [];
            eccentricity = [];
            arg_of_periapsis = [];
            mean_anomaly = [];
            mean_motion = [];
            rev_num_at_epoch = [];
            checksum = [];
            function_events = ConsoleEvent.empty;

            % Check for required length
            TLE_length = 69;
            TLE_input_length = strlength(line_2_text);

            if TLE_input_length ~= TLE_length
                event_message = sprintf('TLE line 2 must be %d characters in length, not %d.', ...
                    TLE_length, TLE_input_length);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
                return
            end
            
            % Make sure the first character is 3
            first_character = str2double(line_2_text(1));
            if first_character ~= 2
                event_message = sprintf('TLE line 2 must start with 2, not %s.', ...
                    first_character);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
                return
            end

            % Check for required empty columns
            empty_space_columns = [2, 8, 17, 26, 34, 43, 52];
            num_empty_spaces = length(empty_space_columns);

            for i = 1:num_empty_spaces
                current_col = empty_space_columns(i);
                input_char = line_2_text(current_col);
                if ~isspace(input_char)
                    event_message = sprintf('Column %d in TLE line 2 must be empty, not %s.', ...
                        current_col, input_char);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
            end
            
            % Check for satellite catalog number
            sat_num_columns = 3:7;
            % If catalog number is completely empty, assign default value
            input_cat_num_str = line_2_text(sat_num_columns);
            if all(isstrprop(input_cat_num_str, 'wspace'))
                default_value = 0;%obj.DefaultSatelliteCatalogNumber;
                catalog_num = default_value;
                event_message = sprintf('Satellite catalog number (column %d through %d) in TLE line 2 not given, assigning default value of %d.', ...
                    sat_num_columns(1), sat_num_columns(end), default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else
                % If it's not empty, attempt to convert the value to a
                % number
                catalog_num = str2double(input_cat_num_str);
                input_invalid = isnan(catalog_num) || ...
                    isinf(catalog_num) || ...
                    ~isreal(catalog_num) || ...
                    mod(catalog_num, 1) ~= 0 || ...
                    catalog_num < 0;

                if input_invalid
                    event_message = sprintf('Satellite catalog number (column %d through %d) in TLE line 2 %s is invalid.', ...
                        sat_num_columns(1), sat_num_columns(end), input_cat_num_str);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
            end

            % Check for inclination
            inclination_columns = 9:16;
            inclination_decimal_column = 12;
            input_inclination = line_2_text(inclination_columns);
            input_inclination_decimal = line_2_text(inclination_decimal_column);
            if all(isstrprop(input_inclination, 'wspace'))
                default_value = 0;
                inclination = default_value;
                event_message = sprintf('Inclination (column %d through %d) in TLE line 2 not given, assigning default value of %f.', ...
                    inclination_columns(1), inclination_columns(end), default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else

                inclination = str2double(input_inclination);
                wrong_inclination = isnan(inclination) || ...
                        isinf(inclination) || ...
                        ~isreal(inclination);
                wrong_input_decimal = ~ismember(input_inclination_decimal, '.');

                if wrong_input_decimal
                    event_message = sprintf('Inclination decimal point (column %d) in TLE line 2 is invalid. Must contian ".", not "%s".', ...
                        inclination_decimal_column, input_inclination_decimal);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

                if wrong_inclination
                    event_message = sprintf('Inclination (column %d through %d) in TLE line 2 not valid. Must contain numeric data, not %s.', ...
                        inclination_columns(1), inclination_columns(end), input_inclination);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

                % Check the physical constraints of angle
                angle_minimum = 0;
                angle_maximum = 180;
                angle_out_of_bounds = (inclination < angle_minimum) || ...
                    (inclination > angle_maximum);
   
                if angle_out_of_bounds
                    event_message = sprintf('Inclination (column %d through %d) in TLE line 2 not valid. Must be in range [%f, %f], not %f.', ...
                        inclination_columns(1), inclination_columns(end), angle_minimum, angle_maximum, inclination);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

            end

            % Check for RAAN
            raan_columns = 18:25;
            raan_decimal_column = 21;
            input_raan = line_2_text(raan_columns);
            input_raan_decimal = line_2_text(raan_decimal_column);
            if all(isstrprop(input_raan, 'wspace'))
                default_value = 0;
                RAAN = default_value;
                event_message = sprintf('Right ascension of ascending node (column %d through %d) in TLE line 2 not given, assigning default value of %f.', ...
                    raan_columns(1), raan_columns(end), default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else

                RAAN = str2double(input_raan);
                wrong_raan = isnan(RAAN) || ...
                        isinf(RAAN) || ...
                        ~isreal(RAAN);

                wrong_input_decimal = ~ismember(input_raan_decimal, '.');

                if wrong_input_decimal
                    event_message = sprintf('Right ascension of ascending node decimal point (column %d) in TLE line 2 is invalid. Must contian ".", not "%s".', ...
                        raan_decimal_column, input_raan_decimal);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
   
                if wrong_raan
                    event_message = sprintf('Right ascension of ascending node (column %d through %d) in TLE line 2 not valid. Must contain numeric data, not %s.', ...
                        raan_columns(1), raan_columns(end), input_raan);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

                % Check the physical constraints of angle
                angle_minimum = 0;
                angle_maximum = 360;
                angle_out_of_bounds = (inclination < angle_minimum) || ...
                    (inclination >= angle_maximum);  % note >=
   
                if angle_out_of_bounds
                    event_message = sprintf('Right ascension of ascending node (column %d through %d) in TLE line 2 not valid. Must be in range [%f, %f), not %f.', ...
                        raan_columns(1), raan_columns(end), angle_minimum, angle_maximum, RAAN);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

            end


            % Check for eccentricity
            eccentricity_columns = 27:33;
            input_eccentricity = line_2_text(eccentricity_columns);
            if all(isstrprop(input_eccentricity, 'wspace'))
                default_value = 0;
                eccentricity = default_value;
                event_message = sprintf('Eccentricity (column %d through %d) in TLE line 2 not given, assigning default value of %f.', ...
                    eccentricity_columns(1), eccentricity_columns(end), default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else

                % Insert implied decimal point
                input_eccentricity_with_decimal = ['.', input_eccentricity];

                eccentricity = str2double(input_eccentricity_with_decimal);
                wrong_eccentricity = isnan(eccentricity) || ...
                        isinf(eccentricity) || ...
                        ~isreal(eccentricity) || ...
                        eccentricity < 0;
   
                if wrong_eccentricity
                    event_message = sprintf('Eccentricity (column %d through %d) in TLE line 2 not valid. Must contain positive numeric integer data (decimal point is implied), not %s.', ...
                    eccentricity_columns(1), eccentricity_columns(end), input_eccentricity);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

            end

            % Check for argument of perigee
            arg_of_perigee_columns = 35:42;
            arg_of_perigee_decimal_column = 38;            
            input_arg_of_perigee = line_2_text(arg_of_perigee_columns);
            input_arg_of_perigee_decimal = line_2_text(arg_of_perigee_decimal_column);

            if all(isstrprop(input_arg_of_perigee, 'wspace'))
                default_value = 0;
                arg_of_periapsis = default_value;
                event_message = sprintf('Argument of periapsis (column %d to %d) in TLE line 2 not given, assigning default value of %f.', ...
                    arg_of_perigee_columns(1), arg_of_perigee_columns(end), default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else
            
                % Managed bad inputs
                arg_of_periapsis = str2double(input_arg_of_perigee);
                wrong_input_arg_of_p =  isnan(arg_of_periapsis) || ...
                    isinf(arg_of_periapsis) || ...
                    ~isreal(arg_of_periapsis);
                wrong_input_decimal = ~ismember(input_arg_of_perigee_decimal, '.');

                if wrong_input_decimal
                    event_message = sprintf('Argument of periapsis decimal point (column %d) in TLE line 2 is invalid. Must contian ".", not "%s".', ...
                        arg_of_perigee_decimal_column, input_arg_of_perigee_decimal);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
    
                if wrong_input_arg_of_p
                    event_message = sprintf('Argument of periapsis (column %d to %d) in TLE line 2 is invalid. Must contian numerical values, not %s.', ...
                        arg_of_perigee_columns(1), arg_of_perigee_columns(end), input_arg_of_perigee);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

                % Check the physical constraints of angle
                angle_minimum = 0;
                angle_maximum = 360;
                angle_out_of_bounds = (arg_of_periapsis < angle_minimum) || ...
                    (arg_of_periapsis >= angle_maximum);  % note >=
   
                if angle_out_of_bounds
                    event_message = sprintf('Argument of periapsis (column %d through %d) in TLE line 2 not valid. Must be in range [%f, %f), not %f.', ...
                        arg_of_perigee_columns(1), arg_of_perigee_columns(end), angle_minimum, angle_maximum, arg_of_periapsis);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

            end

            % Check for mean anomaly
            mean_anomaly_columns = 45:52;
            mean_anomaly_decimal_column = 47;
            input_mean_anomaly = line_2_text(mean_anomaly_columns);
            input_mean_anomaly_decimal = line_2_text(mean_anomaly_decimal_column);

            if all(isstrprop(input_mean_anomaly, 'wspace'))
                default_value = 0;
                mean_anomaly = default_value;
                event_message = sprintf('Mean anomaly (column %d to %d) in TLE line 2 not given, assigning default value of %f.', ...
                    mean_anomaly_columns(1), mean_anomaly_columns(end), default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else
            
                % Managed bad inputs
                wrong_input_decimal = ~ismember(input_mean_anomaly_decimal, '.');
                if wrong_input_decimal
                    event_message = sprintf('Mean anomaly decimal point (column %d) in TLE line 2 is invalid. Must contian ".", not "%s".', ...
                        mean_anomaly_decimal_column, input_mean_anomaly_decimal);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

                mean_anomaly = str2double(input_mean_anomaly);
                wrong_input_second_d =  isnan(mean_anomaly) || ...
                    isinf(mean_anomaly) || ...
                    ~isreal(mean_anomaly);
    
                if wrong_input_second_d
                    event_message = sprintf('Mean anomaly (column %d to %d) in TLE line 2 is invalid. Must contian numerical values, not %s.', ...
                        mean_anomaly_columns(1), mean_anomaly_columns(end), input_mean_anomaly);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end

                % Check the physical constraints of angle
                angle_minimum = 0;
                angle_maximum = 360;
                angle_out_of_bounds = (mean_anomaly < angle_minimum) || ...
                    (mean_anomaly >= angle_maximum);  % note >=
   
                if angle_out_of_bounds
                    event_message = sprintf('Mean anomalu (column %d through %d) in TLE line 2 not valid. Must be in range [%f, %f), not %f.', ...
                        mean_anomaly_columns(1), mean_anomaly_columns(end), angle_minimum, angle_maximum, mean_anomaly);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
            end

            % Check for mean motion
            mean_motion_columns = 53:63;
            mean_motion_decimal_column = 55;
            input_mean_motion = line_2_text(mean_motion_columns);
            input_mean_motion_decimal = line_2_text(mean_motion_decimal_column);
            
            % Managed bad inputs
            wrong_input_decimal = ~ismember(input_mean_motion_decimal, {'.'});
            if wrong_input_decimal
                event_message = sprintf('Mean motion decimal point (column %d) in TLE line 2 is invalid. Must contian ".", not "%s".', ...
                    mean_motion_decimal_column, input_mean_motion_decimal);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
                return
            end

            mean_motion = str2double(input_mean_motion);
            wrong_drag_term =  isnan(mean_motion) || ...
                isinf(mean_motion) || ...
                ~isreal(mean_motion) || ...
                mean_motion <= 0;

            if wrong_drag_term
                event_message = sprintf('Mean motion (column %d to %d) in TLE line 2 is invalid. Must contian positive numerical values, not %s.', ...
                    mean_motion_columns(1), mean_motion_columns(end), input_mean_motion);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
                return
            end

            % Check for revolution number at epoch
            rev_num_columns = 64:68;
            input_rev_num = line_2_text(rev_num_columns);

            if all(isstrprop(input_rev_num, 'wspace'))
                default_value = 0;
                rev_num_at_epoch = default_value;
                event_message = sprintf('Revolution number at epoch (column %d through %d) in TLE line 2 not given, assigning default value of %d.', ...
                    rev_num_columns(1), rev_num_columns(end), default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            else

                % If it's not empty, attempt to convert the value to a
                % number
                rev_num_at_epoch = str2double(input_rev_num);
                input_invalid = isnan(rev_num_at_epoch) || ...
                    isinf(rev_num_at_epoch) || ...
                    ~isreal(rev_num_at_epoch) || ...
                    mod(rev_num_at_epoch, 1) ~= 0 || ...
                    rev_num_at_epoch < 0;

                if input_invalid
                    event_message = sprintf('Revolution number at epoch (column %d through %d) in TLE line 1 is invalid. Must contain postitive integer, not %s.', ...
                        rev_num_columns(1), rev_num_columns(end), input_rev_num);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
            end

            % Check for checksum
            checksum_column = 69;
            input_checksum = line_2_text(checksum_column);
            checksum = str2double(input_checksum);

            % Verify extracted checksum
            input_invalid = isnan(input_checksum) || ...
                isinf(input_checksum) || ...
                ~isreal(input_checksum) || ...
                mod(input_checksum, 1) ~= 0 || ...
                input_checksum < 0;

            if input_invalid
                default_value = 0;
                checksum = 0;
                event_message = sprintf('Checksum (column %d) in TLE line 2 is invalid. Must contain numerical data, not %s. Setting to default value of %d.', ...
                    checksum_column, input_rev_num, default_value);
                event_error_code = StatusCode.Warning;
                new_events = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_events];
            end

            % Send final message to say we have successfully parsed line
            % one
            event_message = sprintf('Successfully parsed TLE line 2 "%s".', line_2_text);
            new_events = ConsoleEvent(event_message);
            function_events = [function_events, new_events];

        end

        % SEBASTIAN'S COMMENT: I haven't touched/used this funct, should we
        % keep it?

        % FIXME: needs better name, and possibly to be merged with a
        % different function of a similar nature (see
        % validateAllTLEFormats)
        function tle_is_valid = validateTLEFormatByName(obj, tle_name_str)
            tle_handle = obj.getTLEByName(tle_name_str);
            tle_is_valid = tle_handle.FormatValid;
        end
% 
%         function [all_tles_valid, invalid_tles] = validateAllTLEFormats(obj)
%             
%             % Automatically return invalid if no TLEs are loaded
%             total_num_tles = length(obj.TLEHandles);
%             if total_num_tles == 0
%                 all_tles_valid = false;
%                 invalid_tles = [];
%                 return
%             end
%             
%             % Loop through currently stored TLEs
%             total_num_tles = length(obj.TLEHandles);
%             tles_valid = false(1, total_num_tles);  % assume it's not valid until we confirm otherwise
%             for i = 1:total_num_tles
% 
%                 % Check validity
%                 current_TLE_is_valid = obj.TLEHandles(i).FormatValid;
% 
%                 % Flag as valid
%                 if current_TLE_is_valid
%                     tles_valid(i) = true;
%                 end
% 
%             end
% 
%             % Check if all TLEs are valid
%             all_tles_valid = all(tles_valid);
% 
%             % Return flagged TLEs
%             invalid_tles = obj.TLEHandles(tles_valid);
% 
%         end
% 
%         function [all_tles_valid, invalid_tles] = validateAllTLEChecksums(obj)
%             
%             % Automatically return invalid if no TLEs are loaded
%             total_num_tles = length(obj.TLEHandles);
%             if total_num_tles == 0
%                 all_tles_valid = false;
%                 invalid_tles = [];
%                 return
%             end
% 
%             % Loop through currently stored TLEs
%             tles_valid = false(1, total_num_tles);
%             for i = 1:total_num_tles
% 
%                 % Check validity
%                 current_TLE_is_valid = obj.TLEHandles(i).ChecksumValid;
% 
%                 % Flag as valid
%                 if current_TLE_is_valid
%                     tles_valid(i) = true;
%                 end
% 
%             end
% 
%             % Check if all TLEs are valid
%             all_tles_valid = all(tles_valid);
% 
%             % Return flagged TLEs
%             invalid_tles = obj.TLEHandles(tles_valid);
%             
%         end
        
function function_events = saveTLEToFile(obj, default_file_name, tle_idxs_to_save, include_name_header, encoding_format, show_save_dialogue)
            % SAVETLETOFILE Helper function to save the TLE data to a file
            %   Detailed explanation goes here

            if nargin < 6
                show_save_dialogue = false;
            end
            if nargin < 5
                encoding_format = obj.DefaultOutputEncodingFormat;
            end
            if nargin < 4
                include_name_header = true;  % should this be false?
            end
            if nargin < 3
                num_TLEs_to_save = length(obj.TLEHandles);
                tle_idxs_to_save = 1:num_TLEs_to_save;
            end
            if nargin < 2
                default_file_name = '';
            end

            % TODO: function events
            function_events = ConsoleEvent.empty;

            % FIXME: The UI portion of this function to select save
            % location should probably be moved into the app code itself?

            num_TLEs_to_save = length(tle_idxs_to_save);
            if num_TLEs_to_save == 0
                event_message = sprintf('No TLE IDs selected for saving. Skipping writing to file.');
                event_error_code = StatusCode.Warning;
                new_event = ConsoleEvent(event_message, event_error_code);
                function_events = [function_events, new_event];
                return
            end
                
            % Prepare a default file name if none given
            first_TLE_idx = tle_idxs_to_save(1);
            first_TLE = obj.TLEHandles(first_TLE_idx);
            if isempty(default_file_name)
                if ~isempty(first_TLE.SatelliteName)
                    % Convert spaces to underscores
                    fixed_satellite_name = first_TLE.SatelliteName;
                    fixed_satellite_name(fixed_satellite_name == ' ') = '_';
                    current_timestamp = string(datetime('now', 'Format', 'yyyyMMddHHmmSS'));
                    default_file_name = strcat(fixed_satellite_name, '_TLE_', current_timestamp);
                else
                    current_timestamp = string(datetime('now', 'Format', 'yyyyMMddHHmmSS'));
                    default_file_name = strcat('TLE_', current_timestamp);
                end
            end

%             % Add default file extension to file name if not included
%             if ~(endsWith(lower(default_file_name), '.tle') || ...
%                     endsWith(lower(default_file_name), '.txt'))
%                 default_file_name = strcat(default_file_name, obj.DefaultOutputFileExtension);
%             end
            
            if show_save_dialogue
                % Prompt user for file
                window_title = 'Save TLE as';
                [file, path] = uiputfile( ...
                    {'*.tle', 'TLE Files'; ...
                    '*.txt', 'Text Files'; ...
                    '*.*', 'All Files'}, ...
                    window_title, default_file_name);
                
                if isequal(file,0)
                    % TODO: Implement Sebastian's fix for this
                    disp('User selected Cancel, did not save.');
                   
                else
                    
                    % Successfully selected a file
                    TLE_dest = fullfile(path,file);
                    fprintf('User selected %s to save file at.\n', TLE_dest);
                end
            else
                TLE_dest = default_file_name;
            end
                
            % Open file, setting encoding type
            if isempty(encoding_format)
                encoding_format = obj.DefaultOutputEncodingFormat;
            end
            if any(ismember(obj.AllowedOutputEncodingFormats, encoding_format))
                TLE_file_ID = fopen(TLE_dest, 'w', 'native', encoding_format);
            else
                % TODO: error handling, and/or remove encoding
                % format stuff entirely
                fprintf('Must encode TLE in either UTF-8 or ASCII! Skipping writing to file.\n')
                return
            end

            for i = 1:num_TLEs_to_save

                current_idx_to_save = tle_idxs_to_save(i);
                current_tle_to_save = obj.TLEHandles(current_idx_to_save);
                
                % Check to see if we need to write satellite name
                if ~isempty(current_tle_to_save.SatelliteName) && include_name_header
                    
                    % Pad or truncate name to 24 characters
                    raw_name = current_tle_to_save.SatelliteName;
                    num_name_chars = length(raw_name);
                    standard_TLE_satellite_name_length = 24;  % this value will never change, so it feels okay to hardcode it
                    if num_name_chars > standard_TLE_satellite_name_length
                        fixed_length_name = raw_name(1:standard_TLE_satellite_name_length);
                    else
                        fixed_length_name = pad(raw_name, standard_TLE_satellite_name_length, 'right', ' ');
                    end
                    
                    % Write fixed length name to file
                    fprintf(TLE_file_ID, '%s\n', fixed_length_name);
                    
                end
                
                % Write TLE lines to file
                TLE_line_1 = current_tle_to_save.TLELine1;
                TLE_line_2 = current_tle_to_save.TLELine2;
                fprintf(TLE_file_ID, '%s\n', TLE_line_1);
                fprintf(TLE_file_ID, '%s', TLE_line_2);

                if i ~= num_TLEs_to_save
                    fprintf(TLE_file_ID, '\n');
                end

            end
            
            % Close file
            fclose(TLE_file_ID);
        
        end

        % function addTLEfromKeplerianElements(obj, satellite_name, semi_major_axis, eccentricity, inclination, RAAN, arg_of_periapsis, mean_motion)
        %     TLE = obj.TLEFactory.createTLEFromKeplerianElements(satellite_name, semi_major_axis, eccentricity, inclination, RAAN, arg_of_periapsis, mean_motion);
        %     obj.addTLE(TLE)
        % end

        function function_events = setCatalogNum(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.CatalogNumber = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for catalog number to %d.', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for catalog number to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end

        end

        function function_events = setClassification(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                new_value = upper(new_value);
                TLE_to_update.Classification = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for classification to "%s".', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for classification to "%s".', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setLaunchYear(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.LaunchYearDesignator = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for launch year to %d.', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for launch year to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setLaunchNumber(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.LaunchNumberDesignator = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for launch number to %d.', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for launch number to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setLaunchPiece(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                new_value = upper(new_value);
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.LaunchPieceDesignator = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for launch piece to "%s".', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for launch piece to "%s".', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setEpochYear(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.EpochYear = new_value;
                TLE_to_update = TLE_to_update.generateEpochDatetimeFromVariables();
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for epoch year to %d.', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for epoch year to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setEpochDay(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.EpochDay = new_value;
                TLE_to_update = TLE_to_update.generateEpochDatetimeFromVariables();
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for epoch day to %d.', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for epoch day to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setEpoch(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.Epoch = new_value;
                TLE_to_update = TLE_to_update.generateEpochVariablesFromDatetime();
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for epoch to %s.', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for epoch to %s.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setFirstDerivofMeanMotion(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.FirstDerivofMeanMotion = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for first derivative of mean motion to %f.', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for first derivative of mean motion to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setSecondDerivofMeanMotion(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.SecondDerivofMeanMotion = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for second derivative of mean motion to %f.', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for second derivative of mean motion to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setBStar(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.BStar = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for ballistic coefficient B* to %f [1/(r_Earth)].', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for ballistic coefficient B* to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setEphemerisType(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.EphemerisType = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for epehemris type to "%s".', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for ephemeris type to "%s".', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setElementSetNum(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.ElementSetNum = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for element set number to %d.', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for element set number to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setChecksum(obj, new_value, line_num, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try

                TLE_to_update = obj.TLEHandles(TLE_index);
                
                if line_num == 1
                    TLE_to_update.ChecksumOne = new_value;
                elseif line_num == 2
                    TLE_to_update.ChecksumTwo = new_value;
                else
                    
                    event_message = sprintf('TLE line checksum to set must be 1 or 2, not %d.', ...
                        TLE_index, new_value);
                    event_error_code = StatusCode.Error;
                    new_event = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_event];
                    return

                end

                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for line %d checksum to %d.', ...
                    TLE_index, line_num, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for line %d checksum to %f.', ...
                    TLE_index, line_num, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setInclination(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.Inclination = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for inclination to %f [deg].', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for inclination to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setRAAN(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.RAAN = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for right ascension of ascending node to %f [deg].', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for right ascension of ascending node to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setEccentricity(obj, new_value, TLE_index, mean_motion_stays_constant)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.Eccentricity = new_value;
                if mean_motion_stays_constant
                    TLE_to_update = TLE_to_update.calculateKeplerianElementsFromSGP4Variables();
                    value_changed_str = 'true anomaly';
                    value_changed = TLE_to_update.TrueAnomaly;
                else
                    TLE_to_update = TLE_to_update.calculateSGP4VariablesFromKeplerianElements();
                    value_changed_str = 'mean anomaly';
                    value_changed = TLE_to_update.MeanAnomaly;
                end
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for eccentricity to %f. Recalculated %s to %f [deg].', ...
                    TLE_index, new_value, value_changed_str, value_changed);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for eccentricity to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setArgOfPeriapsis(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.ArgumentOfPeriapsis = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for argument of perigee to %f [deg].', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for argument of perigee to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setMeanAnomaly(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.MeanAnomaly = new_value;
                % Calculate an updated value for true anomaly
                TLE_to_update = TLE_to_update.calculateKeplerianElementsFromSGP4Variables();
                new_true_anomaly = TLE_to_update.TrueAnomaly;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for mean anomaly to %f [deg]. Recalculated true anomaly to %f [deg].', ...
                    TLE_index, new_value, new_true_anomaly);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for mean anomaly to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setMeanMotion(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.MeanMotion = new_value;
                % Calculate an updated value for semimajor axis
                TLE_to_update = TLE_to_update.calculateKeplerianElementsFromSGP4Variables();
                new_semimajor_axis = TLE_to_update.SemiMajorAxis;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for mean motion to %f [rev/day]. Recalculated semimajor axis to %f [m].', ...
                    TLE_index, new_value, new_semimajor_axis);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for mean motion to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setRevNum(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.RevolutionNoAtEpoch = new_value;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for revolution number at epoch to %d.', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for revolution number at epoch to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setSemimajorAxis(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.SemiMajorAxis = new_value;
                TLE_to_update = TLE_to_update.calculateSGP4VariablesFromKeplerianElements();
                new_mean_motion = TLE_to_update.MeanMotion;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for semimajor axis to %f [m]. Recalculated mean motion to %f [rev/day].', ...
                    TLE_index, new_value, new_mean_motion);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for semimajor axis to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setTrueAnomaly(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.TrueAnomaly = new_value;
                TLE_to_update = TLE_to_update.calculateSGP4VariablesFromKeplerianElements();
                new_mean_anomaly = TLE_to_update.MeanAnomaly;
                TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for true anomaly to %f [deg]. Recalculated true anomaly to %f [deg].', ...
                    TLE_index, new_value, new_mean_anomaly);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for true anomaly to %f.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = setSatelliteName(obj, new_value, TLE_index)
            function_events = ConsoleEvent.empty;
            
            try
                
                TLE_to_update = obj.TLEHandles(TLE_index);
                TLE_to_update.SatelliteName = new_value;
                obj.TLEHandles(TLE_index) = TLE_to_update;

                event_message = sprintf('Set TLE ID %d value for satellite name to %s.', ...
                    TLE_index, new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e

                event_message = sprintf('Unable to set TLE ID %d value for satellite name to %s.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end
        end

        function function_events = updateAllTLEStrings(obj)
            function_events = ConsoleEvent.empty;

            try
                
                total_num_TLEs = length(obj.TLEHandles);
                num_TLEs_updated = 0;

                for i = 1:total_num_TLEs
    
                    TLE_to_update = obj.TLEHandles(i);
                    TLE_to_update = TLE_to_update.generateTLELinesFromStoredVariables(obj.AutoGenerateChecksums);
                    obj.TLEHandles(i) = TLE_to_update;
                    num_TLEs_updated = num_TLEs_updated + 1;
                    
                end

                event_message = sprintf('Updated TLE strings for %d TLEs.', ...
                    num_TLEs_updated);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e
                
                event_message = sprintf('Unable to set TLE ID %d value for satellite name to %s.', ...
                    TLE_index, new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];

            end

        end

        function function_events = setAutoGenerateChecksumsFlag(obj, new_value)
            function_events = ConsoleEvent.empty;

            try

                obj.AutoGenerateChecksums = new_value;

                if new_value
                    new_event = obj.updateAllTLEStrings();
                    function_events = [function_events, new_event];
                end

                event_message = sprintf('Set autogenerate checksums flag to %d.', ...
                    new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e
                event_message = sprintf('Unable to set autogenerate checksums flag to %d.', ...
                    new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];
            end

        end

        function function_events = setIgnoreChecksumsFlag(obj, new_value)
            function_events = ConsoleEvent.empty;

            try

                obj.IgnoreChecksums = new_value;

                if new_value
                    new_event = obj.updateAllTLEStrings();
                    function_events = [function_events, new_event];
                end

                event_message = sprintf('Set ignore checksums flag to %d.', ...
                    new_value);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

            catch e
                event_message = sprintf('Unable to set ignore checksums flag to %d.', ...
                    new_value);
                event_error_code = StatusCode.Error;
                new_event = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_event];
            end

        end

    end


end

