classdef TLE %< handle  % TODO: figure out if this is best defined as a value class or handle class, see https://www.mathworks.com/help/matlab/matlab_oop/which-kind-of-class-to-use.html
    % TLE Object that defines a single Two-Line-Element (TLE) set, which
    % defines the orbital properties of a satellite.
    %   Detailed explanation goes here
    
    properties
        SatelliteName char = ''

        TLELine1 char = ''
        TLELine2 char = ''

        AutoGenerateChecksums logical = false
        IgnoreChecksums logical = false

        % TLE cataloging variables
        CatalogNumber double = 0  % integer?
        Classification char = ''
        LaunchYearDesignator double = 0  % integer? datetime?
        LaunchNumberDesignator double = 0  % integer? char?
        LaunchPieceDesignator char = ''
        Epoch datetime = datetime()  % TODO: better value for this
        EpochYear double = 0   % integer? necessary?
        EpochDay double = 0  % necessary?

        % Added vars for GUI 
        FirstDerivofMeanMotion char = 0
        SecondDerivofMeanMotion char = 0
        EphemerisType double = 0
        ElementSetNum double = 0
        ChecksumOne double = 0

        RevolutionNoAtEpoch double = 0
        ChecksumTwo double = 0

        Argument
        % Keplerian elements
        % FIXME: put units in variable names?
        SemiMajorAxis double = 0
        Eccentricity double = 0
        Inclination double = 0
        RAAN double = 0
        ArgumentOfPeriapsis double = 0  % a.k.a. argument of perigee for geocentric orbits
        TrueAnomaly double = 0
        % SGP4-specific elements
        MeanAnomaly double = 0
        BStar char = 0
        MeanOrbitalPeriod double = 0
    end
    
    % Read-only properties
    properties (SetAccess = private, GetAccess = public)
        FormatValid logical = false
        ChecksumsValid logical = false
    end

    
    methods
        % Update: this class will not have a constructor, since you can
        % build a TLE object from either TLE lines *or* Keplerian elements.
        % Instead, we will initialize a blank TLE object and assign
        % variables afterwards, checking validity along the way.
%         function obj = TLE(satellite_name, line_1, line_2)
%             % TLE Construct an instance of this class
%             %   Detailed explanation goes here
%             obj.SatelliteName = satellite_name;
%             obj.TLELine1 = line_1;
%             obj.TLELine2 = line_2;
% %             obj.IgnoreChecksum = ignore_checksum;
% 
%             % TODO: figure out when and where is best to do this
%             obj.validateTLE();
%         end

        function obj = set.TLELine1(obj, line_str)

            % Check if the inputted line has a valid format before setting
            line_is_valid = obj.validateLine1Format(line_str);
            if line_is_valid
                obj.TLELine1 = line_str;
            else
                warning("Unable to set Line 1 of a TLE ")
            end
        end
        
        function obj = set.TLELine2(obj, line_str)

            % Check if the inputted line has a valid format before setting
            line_is_valid = obj.validateLine2Format(line_str);
            if line_is_valid
                obj.TLELine2 = line_str;
            else
                warning("Unable to set Line 2 of a TLE")
            end
        end

        function value = get.ChecksumsValid(obj)
            % If both lines are empty -> checksum = 0
            % If ignore checksums is checked -> checksum = 1
            % Otherwise, run the function and check validity of checksum
            if isempty(obj.TLELine1) || isempty(obj.TLELine2)
                value = false;
            elseif obj.IgnoreChecksums && ~isempty(obj.TLELine1) && ~isempty(obj.TLELine2)
                value = true;
            else
                % Calculate checksum
                checksum_1_is_valid = obj.validateChecksum(obj.TLELine1);
                checksum_2_is_valid = obj.validateChecksum(obj.TLELine2);
                if checksum_1_is_valid && checksum_2_is_valid
                    value = true;
                end
                if ~checksum_1_is_valid 
                    % warning("The checksum of Line 1 is invalid, the data in the TLE might have been lost.")
                    value = false;
                end
                if ~checksum_2_is_valid 
                    % warning("The checksum of Line 2 is invalid, the data in the TLE might have been lost.")
                    value = false;
                end
            end
        end

        function value = get.FormatValid(obj)
            % If both lines are empty -> formats aren't valid
            % Otherwise -> formats are valid
            if isempty(obj.TLELine1) || isempty(obj.TLELine2)
                value = false;
            else
                value = true;
            end
        end

        function is_valid = validateLine1Format(~, line)
            is_valid = true;
             
            %% Basic length and format check
            TLE_length = 69;
            TLE_input_length = strlength(line);
            first_character = str2double(line(1));

            if TLE_input_length ~= TLE_length
                warning('Line 1 has incorrect length')
                is_valid = false;
                return
            end
            if first_character ~= 1
                warning("Line 1 does not start with the number 1")
                is_valid = false;
                return
            end

            %% Check for required empty columns
            empty_space_columns = [2, 9, 18, 33, 44, 53, 62, 64];
            num_empty_spaces = length(empty_space_columns);

            for i = 1:num_empty_spaces
                if ~isspace(line(empty_space_columns(i)))
                    warning("Column %d in Line 1 is not empty \n", empty_space_columns(i))
                    is_valid = false;
                    return
                end
            end

            %% Check for satellite catalog number
            sat_num_columns = 3:7;
            num_sat_num_columns = length(sat_num_columns);

            for i = 1:num_sat_num_columns
                if ~isstrprop(line(sat_num_columns(i)), "digit") || isempty(line(sat_num_columns(i)))
                    warning("The satellite catalog number must contain numbers and cannot be empty. Columns 3 through 7, Line 1.")
                    is_valid = false;
                    return
                end
            end

            %% Check for classification
            class_column = 8;
            
            if line(class_column) == 'U' || line(class_column) == 'C' || line(class_column) == 'S'
            else
                warning("Unrecognized classification of satellite. Column 8, Line 1.")
                is_valid = false;
                return
            end

            %% Check for international designators
            intl_designator_yr_columns = 10:11;
            intl_designator_num_columns = 12:14;
            intl_designator_piece_columns = 15:17;

            % Check existance of fields
            intl_designator_yr_exists = any(~isspace(line(intl_designator_yr_columns)));
            intl_designator_num_exists = any(~isspace(line(intl_designator_num_columns)));
            intl_designator_piece_exists = any(~isspace(line(intl_designator_piece_columns)));

            % Manage bad inputs
            wrong_input_yr = any(~isstrprop(line(intl_designator_yr_columns), "digit"));
            wrong_input_num = any(~isstrprop(line(intl_designator_num_columns), "digit")); 
            wrong_input_piece = any(isstrprop(line(intl_designator_piece_columns), "punct")) || ...
                 any(isstrprop(line(intl_designator_piece_columns), "digit")) || ... 
                 all(isstrprop(line(intl_designator_piece_columns), "wspace"));

            % If one exists, the others cannot be empty
            if intl_designator_yr_exists || intl_designator_num_exists || intl_designator_piece_exists
                if wrong_input_yr
                    warning("The launch year must be a numerical value and cannot be empty. Columns 10 through 11, Line 1.")
                    is_valid = false;
                    return
                end
                if wrong_input_num
                    warning("The launch number of the year must be a numerical value and cannot be empty. Columns 12 through 14, Line 1.")
                    is_valid = false;
                    return
                end
                if wrong_input_piece
                    warning("The piece of the launch must contain letters and cannot be empty. Columns 15 through 17, Line 1.")
                    is_valid = false;
                    return
                end
            end

            %% Check for Epoch entries
            epoch_yr_columns = 19:20;
            epoch_day_columns = 21:32;

            % Manage bad inputs
            wrong_input_epoch_yr = any(~isstrprop(line(epoch_yr_columns), "digit"));
            wrong_input_epoch_day = ~isfloat(str2double(line(epoch_day_columns)));

            if wrong_input_epoch_yr
                warning("The Epoch year must be a numerical value. Columns 19 through 20, Line 1.")
                is_valid = false;
                return
            end
            if wrong_input_epoch_day
                warning("The Epoch day must be a numerical value. Columns 21 through 32, Line 1.")
                is_valid = false;
                return
            end

            %% Check for Derivative of Motion
            first_derivative_columns = 34:43;
            second_derivative_columns = 45:52;

            % Managed bad inputs
            wrong_input_first_d = ~isfloat(str2double(line(first_derivative_columns))) || ...
                isnan(str2double(line(first_derivative_columns)));
            wrong_input_second_d = any(isstrprop(line(second_derivative_columns), "alpha")); % Multiple formats to keep track of

            if wrong_input_first_d
                warning("The first derivative of mean motion must be a single numerical value. Columns 34 through 43, Line 1.")
                is_valid = false;
                return
            end
            if wrong_input_second_d
                warning("The second derivative of mean motion cannot include letters. Columns 45 through 52, Line 1.")
                is_valid = false;
                return
            end

            %% Check for Drag Term
            drag_term_columns = 54:61;
            
            % Manage bad inputs
            wrong_input_drag = any(isstrprop(line(drag_term_columns), "alpha"));

            if wrong_input_drag
                warning("The drag term cannot include letters. Columns 54 through 61, Line 1.")
                is_valid = false;
                return
            end

            %% Check for Ephemeris Type
            ephemeris_type_column = 63;

            % Manage bad inputs
            wrong_input_ephemeris = str2double(line(ephemeris_type_column)) ~= 0;

            if wrong_input_ephemeris
                warning("The ephemeris type must be 0. Column 63, Line 1.")
                is_valid = false;
                return
            end

            %% Check for Element Set Number
            element_set_num_columns = 65:68;

            % Manage bad inputs
            wrong_input_element = ~isfloat(str2double(line(element_set_num_columns))) || ...
                isnan(str2double(line(element_set_num_columns)));

            if wrong_input_element
                warning("The element set number must be a numerical value. Column 65 through 68, Line 1.")
                is_valid = false;
                return
            end
        end

        % Done?
        function is_valid = validateLine2Format(~, line)
            % TODO: port/rewrite from current app's validate_TLE function
            is_valid = true;

            %% Basic length and format check
            TLE_length = 69;
            TLE_input_length = strlength(line);
            first_character = str2double(line(1));

            if TLE_input_length ~= TLE_length
                warning('Line 2 has incorrect length')
                is_valid = false;
                return
            end
            if first_character ~= 2
                warning("Line 2 does not start with the number 2")
                is_valid = false;
                return
            end

            %% Check for required empty columns
            empty_space_columns = [2, 8, 17, 26, 34, 43, 52];
            num_empty_spaces = length(empty_space_columns);

            for i = 1:num_empty_spaces
                if ~isspace(line(empty_space_columns(i)))
                    warning("Column %d in Line 2 is not empty \n", empty_space_columns(i))
                    is_valid = false;
                    return
                end
            end

            %% Check for satellite catalog number
            sat_num_columns = 3:7;
            num_sat_num_columns = length(sat_num_columns);

            for i = 1:num_sat_num_columns
                if ~isstrprop(line(sat_num_columns(i)), "digit") || isempty(line(sat_num_columns(i)))
                    warning("The satellite catalog number must contain numbers and cannot be empty. Columns 3 through 7, Line 2.")
                    is_valid = false;
                    return
                end
            end

            %% Check for inclination
            inclination_columns = 9:16;

            % Manage bad inputs
            wrong_input_inclination = ~isfloat(str2double(line(inclination_columns))) || ...
                isnan(str2double(line(inclination_columns)));

            if wrong_input_inclination
                warning("The inclination must be a numerical value. Columns 9 through 16, Line 2.")
                is_valid = false;
                return
            end

            %% Check for RAAN
            raan_columns = 18:25;

            % Manage bad inputs
            wrong_input_raan = ~isfloat(str2double(line(raan_columns))) || ...
                isnan(str2double(line(raan_columns)));

            if wrong_input_raan
                warning("The right ascension of the ascending node must be a numerical value. Columns 18 through 25, Line 2.")
                is_valid = false;
                return
            end

            %% Check for Eccentricity
            ecc_columns = 27:33;

            % Manage bad inputs
            wrong_input_ecc = ~isfloat(str2double(line(ecc_columns))) || ...
                isnan(str2double(line(ecc_columns)));

            if wrong_input_ecc
                warning("The eccentricity must be a numerical value. Columns 27 through 33, Line 2.")
                is_valid = false;
                return
            end

            %% Check for Argument of Perigee
            arg_perigee_columns = 35:42;

            % Manage bad inputs
            wrong_input_arg_perigee = ~isfloat(str2double(line(arg_perigee_columns))) || ...
                isnan(str2double(line(arg_perigee_columns)));

            if wrong_input_arg_perigee
                warning("The argument of perigee must be a numerical value. Columns 35 through 42, Line 2.")
                is_valid = false;
                return
            end

            %% Check for Mean Anomaly
            mean_anomaly_columns = 44:51;

            % Manage bad inputs
            wrong_input_mean_anomaly = ~isfloat(str2double(line(mean_anomaly_columns))) || ...
                isnan(str2double(line(mean_anomaly_columns)));

            if wrong_input_mean_anomaly
                warning("The mean anomaly must be a numerical value. Columns 44 through 51, Line 2.")
                is_valid = false;
                return
            end

            %% Check for Mean Motion
            mean_motion_columns = 53:63;

            % Manage bad inputs
            wrong_input_mean_motion = ~isfloat(str2double(line(mean_motion_columns))) || ...
                isnan(str2double(line(mean_motion_columns)));

            if wrong_input_mean_motion
                warning("The mean motion must be a numerical value. Columns 53 through 63, Line 2.")
                is_valid = false;
                return
            end

            %% Check for Revolution Number at Epoch
            rev_num_epoch_columns = 64:68;

            % Manage bad inputs
            wrong_input_rev_num = ~isfloat(str2double(line(rev_num_epoch_columns))) || ...
                isnan(str2double(line(rev_num_epoch_columns)));

            if wrong_input_rev_num
                warning("The revolution number at epoch must be a numerical value. Columns 64 through 68, Line 2.")
                is_valid = false;
                return
            end

            %% Chek for checksum
            checksum = str2double(line(end));

            % Verify extracted checksum
            if ~isfloat(checksum) || isnan(checksum)
                warning("The checksum must be a numerical value. Column 69, Line %s. \n", line(1))
                return
            end
        end

        %% Checksum
        function line_is_valid = validateChecksum(~, line)
            % TODO: port/rewrite from current app's validate_TLE function
            % Booleans to output
            line_is_valid = false;
    
            % Extract checksum from lines
            checksum = str2double(line(end));

            % Remove the last character, which is the checksum character
            line = line(1:end-1);

            % Replace '-' with 1
            line(line == '-') = '1';

            % Convert non-numeric characters to 0
            line(~isstrprop(line, 'digit')) = '0';

            % Convert the remaining characters to doubles and sum them up
            checksum_calc = 0;

            for i = 1:strlength(line)
                checksum_calc = checksum_calc + str2double(line(i));
            end

            % Take the mod 10 of the checksum
            checksum_calc = mod(checksum_calc, 10);

            % Compare and check
            if checksum == checksum_calc
                line_is_valid = true;
            end
        end

        %% Assign variables to object from Line
        function obj = assignVariablesFromStoredTLELines(obj)
            % TODO: port/rewrite

            % Check if currently stored TLE format is valid
            if obj.FormatValid
                % Extract orbital information from TLE
                % TODO
                % Line 1
%                 app. = name   
                obj.CatalogNumber = str2double(obj.TLELine1(3:7));
                obj.Classification = obj.TLELine1(8);
                obj.LaunchYearDesignator = str2double(obj.TLELine1(10:11));
                obj.LaunchNumberDesignator = str2double(obj.TLELine1(12:14));
                obj.LaunchPieceDesignator = obj.TLELine1(15:17);
                obj.EpochYear = str2double(obj.TLELine1(19:20));
                obj.EpochDay = str2double(obj.TLELine1(21:32));
                obj.FirstDerivofMeanMotion = obj.TLELine1(34:43);
                obj.SecondDerivofMeanMotion = obj.TLELine1(45:52);
                obj.BStar = obj.TLELine1(54:61);
                obj.EphemerisType = str2double(obj.TLELine1(63));
                obj.ElementSetNum = str2double(obj.TLELine1(65:68));
                obj.ChecksumOne = str2double(obj.TLELine1(69));

                % Line 2
                obj.Inclination = str2double(obj.TLELine2(9:16));
                obj.RAAN = str2double(obj.TLELine2(18:25));
                obj.Eccentricity = str2double(strcat('.', obj.TLELine2(27:33)));
                obj.ArgumentOfPeriapsis = str2double(obj.TLELine2(35:42));
                obj.MeanAnomaly = str2double(obj.TLELine2(44:51));
                obj.MeanOrbitalPeriod = str2double(obj.TLELine2(53:63));
                obj.RevolutionNoAtEpoch = str2double(obj.TLELine2(64:68));
                obj.ChecksumTwo = str2double(obj.TLELine2(69));

                % Get checksum 
                obj.ChecksumsValid;
            end
        end

        function obj = generateTLELinesFromStoredVariables(obj)
            % TODO
            obj.TLELine1 = 'line 1 text';
            obj.TLELine2 = 'line 2 text';
        end

    end
end
