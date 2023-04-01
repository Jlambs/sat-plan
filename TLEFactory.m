classdef TLEFactory < handle
    % TLEFACTORY A helper factory for easily generating TLE objects from
    % different sources.
    %   Detailed explanation goes here
    
    methods

        function new_TLE_output = createTLEFromFile(~, file_name, ignore_checksums, TLE_to_load)

            % Load file lines
            TLE_lines = strtrim(readlines(file_name));

            % Number of TLEs
            total_lines = size(TLE_lines);

            % Pre-create matrices & variables
            names_mat = string();
            line_1_mat = string();
            line_2_mat = string();
            
            num_of_TLE_line_1 = 1;
            num_of_TLE_line_2 = 1;

            % Parse through every line, allocates lines
            for i = 1:total_lines
                % Get line
                line = TLE_lines{i};
                
                if ~isempty(line)
                    % Determine first and second characters
                    first_char = line(1);
                    second_char = line(2);

                    if isstrprop(first_char, "alpha") || (isstrprop(first_char, "digit") && ~isstrprop(second_char, "wspace"))
                        if numel(line_1_mat)^2 > numel(line_1_mat)^2
                            % Line 1 is bigger so the names matrix's size should be based on
                            % Line 1's size
                            num_of_TLEs = num_of_TLE_line_1;

                        elseif numel(line_1_mat)^2 == numel(line_1_mat)^2
                            % Line 1 is the same size as Line 2. Either works for indexing
                            num_of_TLEs = num_of_TLE_line_1;

                        else
                            % Line 2 is bigger so the names matrix's size should be based on
                            % Line 2's size
                            num_of_TLEs = num_of_TLE_line_2;
                            
                        end

                        names_mat(num_of_TLEs, 1) = line;

                    end
                    if strcmp(first_char, "1") && isstrprop(second_char, "wspace")
                        % First line detected
                        line_1_mat(num_of_TLE_line_1, 1) = line;
                        num_of_TLE_line_1 = num_of_TLE_line_1 + 1;

                    end
                    if strcmp(first_char, "2") && isstrprop(second_char, "wspace")
                        % Second line detected
                        line_2_mat(num_of_TLE_line_2, 1) = line;
                        num_of_TLE_line_2 = num_of_TLE_line_2 + 1;

                    end
                end
            end

            % If there is no name in the TLE, assign a placeholder
            max_size = max([numel(names_mat), numel(line_1_mat), numel(line_2_mat)]);

            % Fix for when the TLE has no name
            for i = 1:max_size
                    % If a name is missing and the sizes are not the same, assign placeholder
                    if numel(names_mat) < max_size
                        names_mat = vertcat(names_mat, "");
                        num_of_TLEs = numel(names_mat);
                    end
                    % If a name is missing and the sizes are the same, assign placeholder
                    if ismissing(names_mat(i))
                        names_mat(i) = "";
                        num_of_TLEs = numel(names_mat);
                    end
            end

            % Assign number of TLEs if there is only one and it's empty
            if isequal(names_mat, "")
                num_of_TLEs = 1;
            end

            % If there is an empty line in either line matrix, delete it
            min_size = min([numel(names_mat), numel(line_1_mat), numel(line_2_mat)]);

            i = 1;
            while i < min_size
                if ismissing(line_1_mat(i))
                    line_1_mat(i) = [];
                end
                if ismissing(line_2_mat(i))
                    line_2_mat(i) = [];
                end
                i = i + 1;
            end

            % If the lines matrices size's don't match, abort mission
            if numel(line_1_mat) ~= numel(line_2_mat)
                warning("There is one or more TLE lines missing. Couldn't load file.")
                new_TLE_output = '';
                return
            end

            % For loop variables
            TLE_output_number = 1;
            TLEs_found = 1;
            TLE_found = 0;

            for i = 1:num_of_TLEs

                % Determine which satellite to load from file
                sat_name = strtrim(char(names_mat(i)));

                line_1 = char(line_1_mat(i));
                sat_num = line_1(3:7);

                if isempty(TLE_to_load)
                    % Create objects
                    new_TLE = ['TLE_Number_', num2str(i)];
                    eval([new_TLE, ' = TLE();']);

                    % If ignore checksums is clicked
                    if ignore_checksums
                        eval([new_TLE, '.IgnoreChecksums = ignore_checksums;']);
                    end

                    % Create the TLE
                    eval([new_TLE, '.SatelliteName = strtrim(names_mat(i));']);
                    eval([new_TLE, '.TLELine1 = line_1_mat(i);']);
                    eval([new_TLE, '.TLELine2 = line_2_mat(i);']);

                    % If name of satellite is a placeholder, replace the
                    % placeholder with the satellite number 
                    name = eval([new_TLE, '.SatelliteName;']);

                    if isempty(name)
                        eval([new_TLE, '.SatelliteName = strtrim(sat_num);']);
                    end                    

                    % Notifies the user if the checksum is invalid. Still
                    % lets the user set the lines of the TLE
                    checksums_valid = eval([new_TLE, '.ChecksumsValid']);

                    % If either line is invalid, delete the tle. Otherwise,
                    % create and populate the TLE
                    if isempty(eval([new_TLE, '.TLELine1'])) || isempty(eval([new_TLE, '.TLELine2']))
                        eval([new_TLE, ' = TLE();']);
                    else

                        % Assign all variables based on the valid TLE
                        eval([new_TLE, ' = ', new_TLE, '.assignVariablesFromStoredTLELines;']) % This somehow works


                    if checksums_valid
                    else
                        checksum_1_is_valid = eval([new_TLE, '.validateChecksum(cell2mat(line_1_mat(i)))']);
                        checksum_2_is_valid = eval([new_TLE, '.validateChecksum(cell2mat(line_2_mat(i)))']);
                        if ~checksum_1_is_valid
                            warning("The checksum of Line 1 in the %s TLE is invalid, the data in the TLE might have been lost.", names_mat(i))
                        end
                        if ~checksum_2_is_valid
                            warning("The checksum of Line 2 in the %s TLE is invalid, the data in the TLE might have been lost.", names_mat(i))
                        end
                    end

                        % This is the best way I managed to do this, I think it's
                        % worth the error message
                        new_TLE_output(TLE_output_number, 1) = eval(['TLE_Number_', num2str(i)]);

                        TLE_output_number = TLE_output_number + 1;

                        TLE_found = 1;
                    end
                elseif strcmp(TLE_to_load, sat_num) || strcmp(TLE_to_load, sat_name)
                    % If the user wants only specific TLEs from file

                    % Create objects
                    new_TLE = ['TLE_Number_', num2str(TLEs_found)];
                    eval([new_TLE, ' = TLE();']);

                    % If ignore checksums is clicked
                    if ignore_checksums
                        eval([new_TLE, '.IgnoreChecksums = ignore_checksums;']);
                    end

                    eval([new_TLE, '.SatelliteName = names_mat(i);']);
                    eval([new_TLE, '.TLELine1 = line_1_mat(i);']);
                    eval([new_TLE, '.TLELine2 = line_2_mat(i);']);

                    % Assign all variables based on the valid TLE
                    eval([new_TLE, ' = ', new_TLE, '.assignVariablesFromStoredTLELines;']) % This somehow works

                    % Notifies the user if the checksum is invalid. Still
                    % lets the user set the lines of the TLE
                    checksums_valid = eval([new_TLE, '.ChecksumsValid']);

                    if checksums_valid
                    else
                        checksum_1_is_valid = eval([new_TLE, '.validateChecksum(cell2mat(line_1_mat(i)))']);
                        checksum_2_is_valid = eval([new_TLE, '.validateChecksum(cell2mat(line_2_mat(i)))']);
                        if ~checksum_1_is_valid
                            warning("The checksum of Line 1 in the %s TLE is invalid, the data in the TLE might have been lost.", names_mat(i))
                        end
                        if ~checksum_2_is_valid
                            warning("The checksum of Line 2 in the %s TLE is invalid, the data in the TLE might have been lost.", names_mat(i))
                        end
                    end

                    % This is the best way I managed to do this, I think it's
                    % worth the error message
                    new_TLE_output(TLEs_found, 1) = eval(['TLE_Number_', num2str(TLEs_found)]);

                    TLEs_found = TLEs_found + 1;

                    TLE_found = 1;
                end
            end

            % If the TLE was not found, error
            if ~TLE_found
                warning('Unable to load the TLE in the file')
                new_TLE_output = '';
            end
        end

        function TLE = findTLE(~, TLE_strings, sat_num_or_name)
            % Find tle based on name or catalog number

            % While loop variables
            found_name = false;
            found_num = false; 
            i = 1;

            % Trim input to facilitate search
            num_or_name = strtrim(sat_num_or_name);
            
            % Parse through every TLE and find the right one
            while i < numel(TLE_strings)

                % Get first and second characters of the line
                line = cell2mat(TLE_strings(i));
                first_char = line(1);
                second_char = line(2);

                % Determine if the line is a name or a line 1 type
                if isstrprop(first_char, "alpha") || (isstrprop(first_char, "digit") && ~isstrprop(second_char, "wspace"))
   
                    % If the name line and the name match, you found the
                    % right TLE
                    if strcmp(num_or_name, strtrim(line))
                        found_name = true;
                    end

                end
                if strcmp(first_char, "1") && isstrprop(second_char, "wspace")
                    sat_num_in_line = line(3:7);

                    % If the line 1 satellite number and the satellite
                    % number match, you found the right TLE
                    if strcmp(sat_num_in_line, num_or_name)
                        found_num = true;
                    end
                end

                % Assign values
                if found_name
                    sat_name_line = strtrim(line);
                    sat_line_1 = cell2mat(TLE_strings(i + 1));
                    sat_line_2 = cell2mat(TLE_strings(i + 2));
                    i = numel(TLE_strings); % If found, end while loop
                end
                if found_num
                    sat_name_line = strtrim(cell2mat(TLE_strings(i - 1)));
                    sat_line_1 = line;
                    sat_line_2 = cell2mat(TLE_strings(i + 1));
                    i = numel(TLE_strings); % If found, end while loop
                end
                if ~found_num && ~found_name
                    sat_name_line = '';
                    sat_line_1 = '';
                    sat_line_2 = '';
                end
                i = i + 1;
            end

            % If it couldn't find the TLE, return empty cell, else return
            % the found TLE
            if isempty(sat_name_line) || isempty(sat_line_1) || isempty(sat_line_2) 
                warning("Unable to find the %s satellite", sat_num_or_name)
                TLE = '';
            else
                TLE = {sat_name_line; sat_line_1; sat_line_2};
            end

        end

        function new_TLE_object = createTLEFromURL(obj, url_string, ignore_checksum, sat_num_or_name)%, name_or_catalog_num)
            
            % Read data from website
            TLE_raw_text = webread(url_string);
            TLE_strings = splitlines(TLE_raw_text);

            % Find TLE in the website
            TLE_found = findTLE(obj, TLE_strings, sat_num_or_name);

            if ~isempty(TLE_found)
                new_TLE_object = TLE();

                % Ignore checksum check
                if ignore_checksum
                    new_TLE_object.IgnoreChecksums = ignore_checksum;
                end

                % Createobject
                new_TLE_object.SatelliteName = TLE_found{1};
                new_TLE_object.TLELine1 = TLE_found{2};
                new_TLE_object.TLELine2 = TLE_found{3};

                % Assign all variables based on the valid TLE
                new_TLE_object = new_TLE_object.assignVariablesFromStoredTLELines;
            else
                % No search input
                new_TLE_object = '';
            end
        end

        function new_TLE_object = createTLEFromKeplerianElements(~, satellite_name, semi_major_axis, eccentricity, inclination, RAAN, arg_of_periapsis, mean_motion)
            % TODO: allow creating multiple TLE objects if inputs are
            % vectors
           
            new_TLE_object = TLE();
            new_TLE_object.SatelliteName = satellite_name;
            new_TLE_object.SemiMajorAxis = semi_major_axis;
            new_TLE_object.Eccentricity = eccentricity;
            new_TLE_object.Inclination = inclination;
            new_TLE_object.RAAN = RAAN;
            new_TLE_object.MeanOrbitalPeriod = mean_motion;
            new_TLE_object.ArgumentOfPeriapsis = arg_of_periapsis;

            new_TLE_object.CatalogNumber = '';
            new_TLE_object.Classification = '';
            new_TLE_object.LaunchYearDesignator = '';
            new_TLE_object.LaunchNumberDesignator = '';
            new_TLE_object.LaunchPieceDesignator = '';
            new_TLE_object.EpochYear = '';
            new_TLE_object.EpochDay = '';
            new_TLE_object.FirstDerivofMeanMotion = '';
            new_TLE_object.SecondDerivofMeanMotion = '';
            new_TLE_object.BStar = '';
            new_TLE_object.EphemerisType = '';
            new_TLE_object.ElementSetNum = '';
            new_TLE_object.ChecksumOne = '';


        
        end

        % See https://www.mathworks.com/help/satcom/ref/matlabshared.satellitescenario.satellite.orbitalelements.html
        function [new_TLE_object, is_valid] = createTLEFromSGP4Elements(~, satellite_name, semi_major_axis, eccentricity, inclination, RAAN, arg_of_periapsis, mean_anomaly, epoch, B_star, mean_orbital_period)

            % TODO: allow creating multiple TLE objects if inputs are
            % vectors
           
            new_TLE_object = TLE();
            new_TLE_object.SatelliteName = satellite_name;
            new_TLE_object.SemiMajorAxis = semi_major_axis;
            new_TLE_object.Eccentricity = eccentricity;
            new_TLE_object.Inclination = inclination;
            new_TLE_object.RAAN = RAAN;
            new_TLE_object.ArgumentOfPeriapsis = arg_of_periapsis;
            % SGP4-specific elements
            new_TLE_object.MeanAnomaly = mean_anomaly; 
            new_TLE_object.Epoch = epoch;
            new_TLE_object.BStar = B_star;
            new_TLE_object.MeanOrbitalPeriod = mean_orbital_period;

            is_valid = new_TLE_object.FormatValid;  % not sure if you actually need to return this, or just check it later
        
        end

    end

end

