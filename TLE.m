classdef TLE %< handle  % TODO: figure out if this is best defined as a value class or handle class, see https://www.mathworks.com/help/matlab/matlab_oop/which-kind-of-class-to-use.html
    % TLE Object that defines a single Two-Line-Element (TLE) set, which
    % defines the orbital properties of a satellite.
    %   Detailed explanation goes here

    properties

        TLELine1(1,69) char {mustBeTextScalar}
        TLELine2(1,69) char {mustBeTextScalar}

        % TLE line 1 variables
        % FIXME: put units in variable names?
        CatalogNumber double {mustBeInteger, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal}  % note only one reference to catalog number
        Classification(1,1) char {mustBeTextScalar, mustBeMember(Classification, {'U', 'C', 'S'})} = 'U'
        LaunchYearDesignator double {mustBeInteger, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThanOrEqual(LaunchYearDesignator, 99)}
        LaunchNumberDesignator double {mustBeInteger, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThanOrEqual(LaunchNumberDesignator, 999)}
        LaunchPieceDesignator char {mustBeTextScalar}%, mustBeNonempty} = 'A' % restric to 1-3 chars?
        EpochYear double {mustBeInteger, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThanOrEqual(EpochYear, 2056), mustBeGreaterThanOrEqual(EpochYear, 1957)}  % mustBeNonnegative is redundant here
        EpochDay double {mustBeFloat, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThan(EpochDay, 366.25)}  % 366.25 days seems reasonable
        FirstDerivofMeanMotion double {mustBeFloat, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThan(FirstDerivofMeanMotion, 1), mustBeGreaterThan(FirstDerivofMeanMotion, -1)} 
        SecondDerivofMeanMotion double {mustBeFloat, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThanOrEqual(SecondDerivofMeanMotion, 99999e9)}
        BStar double {mustBeFloat,mustBeNonNan, mustBeFinite, mustBeReal}
        EphemerisType(1,1) char {mustBeTextScalar}
        ElementSetNum double {mustBeInteger, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThanOrEqual(ElementSetNum, 9999)}  % seems like this only goes up to 999 in practice
        ChecksumOne double {mustBeInteger, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThanOrEqual(ChecksumOne, 9)}

        % TLE line 2 variables
        Eccentricity double {mustBeFloat, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThan(Eccentricity, 1)}
        Inclination double {mustBeFloat, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThanOrEqual(Inclination, 180)}  % 0deg <= i <= 180deg
        RAAN double {mustBeFloat, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThan(RAAN, 360)}
        ArgumentOfPeriapsis double {mustBeFloat, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThan(ArgumentOfPeriapsis, 360)}  % a.k.a. argument of perigee for geocentric orbits
        MeanAnomaly double {mustBeFloat, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThan(MeanAnomaly, 360)}
        MeanMotion double {mustBeFloat, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeGreaterThan(MeanMotion, 6.5), mustBeLessThan(MeanMotion, 100)}  % lower bound is approximate, to avoid performance issues with propagator
        RevolutionNoAtEpoch double {mustBeInteger, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThanOrEqual(RevolutionNoAtEpoch, 99999)}
        ChecksumTwo double {mustBeInteger, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThanOrEqual(ChecksumTwo, 9)}

        % Keplerian elements
        % These are automatically converted to/from equivalent SGP4 values
        SemiMajorAxis double {mustBeFloat, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThan(SemiMajorAxis, 1.2e7), mustBeGreaterThan(SemiMajorAxis, 6400000)}  % 6400km just above r_Earth
        TrueAnomaly double {mustBeFloat, mustBeNonnegative, mustBeNonNan, mustBeFinite, mustBeReal, mustBeLessThanOrEqual(TrueAnomaly, 360)}

        % Housekeeping variables
        SatelliteName(1,:) char {mustBeTextScalar}
        DefaultNamePrefix(1,:) char {mustBeTextScalar} = 'Satellite'
        Epoch datetime  % automatically converted to/from EpochYear and EpochDay

        % Checksum options
        AutoGenerateChecksums logical
        IgnoreChecksums logical

    end

    % Read-only properties
    properties (SetAccess = private, GetAccess = public)
        % FormatValid logical = false
        Checksum1Valid logical = false
        Checksum2Valid logical = false
    end


    methods

        function obj = TLE(satellite_name, cat_num_1, classification, ...
                    intl_designator_year, intl_designator_launch_num, ...
                    intl_designator_piece, epoch_year, epoch_day, ...
                    first_deriv_of_mean_motion, second_deriv_of_mean_motion, ...
                    b_star, ephemeris_type, element_set_num, checksum_1, ...
                    inclination, raan, eccentricity, arg_of_periapsis, ...
                    mean_anomaly, mean_motion, rev_num_at_epoch, checksum_2)

            % Variables from TLE line 1
            obj.CatalogNumber = cat_num_1;
            obj.Classification = classification;
            obj.LaunchYearDesignator = intl_designator_year;
            obj.LaunchNumberDesignator = intl_designator_launch_num;
            obj.LaunchPieceDesignator = intl_designator_piece;
            obj.EpochYear = epoch_year;
            obj.EpochDay = epoch_day;
            obj.FirstDerivofMeanMotion = first_deriv_of_mean_motion;
            obj.SecondDerivofMeanMotion = second_deriv_of_mean_motion;
            obj.BStar = b_star;
            obj.EphemerisType = ephemeris_type;
            obj.ElementSetNum = element_set_num;
            obj.ChecksumOne = checksum_1;

            % Variables from TLE line 2
            obj.Inclination = inclination;
            obj.RAAN = raan;
            obj.Eccentricity = eccentricity;
            obj.ArgumentOfPeriapsis = arg_of_periapsis;
            obj.MeanAnomaly = mean_anomaly;
            obj.MeanMotion = mean_motion;
            obj.RevolutionNoAtEpoch = rev_num_at_epoch;
            obj.ChecksumTwo = checksum_2;

            % Convert epoch to datetime
            [obj, ~] = obj.generateEpochDatetimeFromVariables();

            % Convert SGP4 variables to Keplerian elements
            [obj, ~] = obj.calculateKeplerianElementsFromSGP4Variables();

            % Generate TLE lines
            [obj, ~] = obj.generateTLELinesFromStoredVariables();

            % Set satellite name
            if isempty(satellite_name)
                default_name = obj.generateDefaultName();
                satellite_name = default_name;
            end
            obj.SatelliteName = satellite_name;

        end

        % function obj = set.CatalogNumber(obj, new_value)
        %     obj.CatalogNumber = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.Classification(obj, new_value)
        %     obj.Classification = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.LaunchYearDesignator(obj, new_value)
        %     obj.LaunchYearDesignator = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.LaunchNumberDesignator(obj, new_value)
        %     obj.LaunchNumberDesignator = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.LaunchPieceDesignator(obj, new_value)
        %     obj.LaunchPieceDesignator = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.EpochYear(obj, new_value)
        %     obj.EpochYear = new_value;
        %     obj = obj.generateEpochDatetimeFromVariables();
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.EpochDay(obj, new_value)
        %     obj.EpochDay = new_value;
        %     obj = obj.generateEpochDatetimeFromVariables();
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.Epoch(obj, new_value)
        %     obj.Epoch = new_value;
        %     obj = obj.generateEpochVariablesFromDatetime();
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.FirstDerivofMeanMotion(obj, new_value)
        %     obj.FirstDerivofMeanMotion = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.SecondDerivofMeanMotion(obj, new_value)
        %     obj.SecondDerivofMeanMotion = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.BStar(obj, new_value)
        %     obj.BStar = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.EphemerisType(obj, new_value)
        %     obj.EphemerisType = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.ElementSetNum(obj, new_value)
        %     obj.ElementSetNum = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.ChecksumOne(obj, new_value)
        %     obj.ChecksumOne = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.Inclination(obj, new_value)
        %     obj.Inclination = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.RAAN(obj, new_value)
        %     obj.RAAN = new_value;
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end
        % 
        % function obj = set.Eccentricity(obj, new_value)
        %     obj.Eccentricity = new_value;
        %     % NOTE: changing this value will have implications on either
        %     % mean anomaly OR true anomaly, depending on which is held
        %     % constant. This means that the relevant call in TLE handler
        %     % should determine whether to issue an additional call to
        %     % calculateKeplerianElementsFromSGP4Variables or 
        %     % calculateSGP4VariablesFromKeplerianElements, which in turn
        %     % will generate new TLE strings
        %     obj = obj.generateTLELinesFromStoredVariables();
        % end

        

        function [obj, function_events] = calculateKeplerianElementsFromSGP4Variables(obj)
            function_events = ConsoleEvent.empty;

            % try
                
                % FIXME: is there a built-in function(s) for this stuff?
                mean_motion = obj.MeanMotion;
                semimajor_axis = meanMotionToSemimajorAxis(mean_motion);

                event_message = sprintf('Converted mean motion %f (rev/day) to semi-major axis %f (m).', ...
                    mean_motion, semimajor_axis);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

                % Convert mean anomaly to true anomaly
                mean_anomaly = obj.MeanAnomaly;
                eccentricity = obj.Eccentricity;
                max_eccentricity = 0.6627;  % won't actually stop you from performing the conversion, just issue a warning
                if eccentricity > max_eccentricity
                    event_message = sprintf('Conversion between mean anomaly and true anomaly is unreliable for values above %f. Input eccentricity is %f.', ...
                    max_eccentricity, eccentricity);
                    event_error_code = StatusCode.Warning;
                    new_event = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_event];
                end

                true_anomaly = meanAnomalyToTrueAnomalyd(mean_anomaly, eccentricity);

                event_message = sprintf('Converted mean anomaly %f (deg) to true anomaly %f (deg).', ...
                    mean_anomaly, true_anomaly);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];
                
                % Set variables
                obj.SemiMajorAxis = semimajor_axis;
                obj.TrueAnomaly = true_anomaly;

            % catch e
            %     event_message = sprintf('Unable to calculate Keplerian variables from stored SGP4 variables. Values not set.');
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [obj, function_events] = calculateSGP4VariablesFromKeplerianElements(obj)
            function_events = ConsoleEvent.empty;

            % try
                
                % FIXME: is there a built-in function(s) for this stuff?

                % Convert semi-major axis to mean_motion
                semimajor_axis = obj.SemiMajorAxis;
                mean_motion_rev_per_day = semimajorAxisToMeanMotion(semimajor_axis);

                event_message = sprintf('Converted semi-major axis %f (m) to mean motion %f (rev/day).', ...
                    semimajor_axis, mean_motion_rev_per_day);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];

                % Convert true anomaly to mean anomaly
                % Use formula found here https://en.wikipedia.org/wiki/Mean_anomaly#Formulae
                % Note: accurate for small values of e, e > 0.6627... may
                % have unpredictable results
                true_anomaly_deg = obj.TrueAnomaly;
                eccentricity = obj.Eccentricity;
                max_eccentricity = 0.6627;  % won't actually stop you from performing the conversion, just issue a warning
                if eccentricity > max_eccentricity
                    event_message = sprintf('Conversion between mean anomaly and true anomaly is unreliable for values above %f. Input eccentricity is %f.', ...
                    max_eccentricity, eccentricity);
                    event_error_code = StatusCode.Warning;
                    new_event = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_event];
                end

                mean_anomaly_deg = trueAnomalyToMeanAnomalyd(true_anomaly_deg, eccentricity);

                event_message = sprintf('Converted true anomaly %f (deg) to mean anomaly %f (deg).', ...
                    true_anomaly_deg, mean_anomaly_deg);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];
                
                % Set variables
                obj.MeanMotion = mean_motion_rev_per_day;
                obj.MeanAnomaly = mean_anomaly_deg;

                % % Update TLE strings since SGP4 variables have changed
                % % Nvm, do this in their set methods instead
                % [obj, new_event] = obj.generateTLELinesFromStoredVariables();
                % function_events = [function_events, new_event];

            % catch e
            %     event_message = sprintf('Unable to calculate SGP4 variables from stored Keplerian elements. Values not set.');
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [default_name, function_events] = generateDefaultName(obj)
            function_events = ConsoleEvent.empty;
            % default_name = '';

            % try
                % Default name is simply the catalog number converted to a
                % string preceeded by some default prefix
                [catalog_num_str, new_events] = obj.generateCatalogNumString();
                default_prefix = obj.DefaultNamePrefix;
                default_name = [default_prefix, blanks(1), catalog_num_str];
                function_events = [function_events, new_events];
            % catch e
            %     event_message = sprintf('Unable to generate default satellite name, returning empty string.');
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [obj, function_events] = generateEpochDatetimeFromVariables(obj)
            function_events = ConsoleEvent.empty;

            % try
                epoch_year = obj.EpochYear;
                
                epoch_day = obj.EpochDay;

                epoch_datetime = yearAndDOYToDatetime(epoch_year, epoch_day);

                obj.Epoch = epoch_datetime;

                event_message = sprintf('Converted epoch year %d and day %f to datetime %s.', ...
                    epoch_year, epoch_day, epoch_datetime);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];
                
            % catch e
            %     event_message = sprintf('Unable to convert epoch year %d and day %f to datetime.', ...
            %         epoch_year, epoch_day);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [obj, function_events] = generateEpochVariablesFromDatetime(obj)
            function_events = ConsoleEvent.empty;

            % try
                epoch_datetime = obj.Epoch;
                [epoch_year, epoch_day] = datetimeToYearAndDOY(epoch_datetime);

                event_message = sprintf('Converted epoch datetime %s to year %d and day %f.', ...
                    epoch_datetime, epoch_year, epoch_day);
                new_event = ConsoleEvent(event_message);
                function_events = [function_events, new_event];
                
            % catch e
            %     event_message = sprintf('Unable to convert epoch datetime %s to year and day.', ...
            %         epoch_datetime);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [catalog_num_str, function_events] = generateCatalogNumString(obj)%, catalog_num)
            catalog_num_str = '';
            function_events = ConsoleEvent.empty;
            % if nargin < 2
            %     catalog_num = obj.CatalogNumber;
            % end

            % try
                catalog_num = obj.CatalogNumber;
                catalog_num_str = sprintf('%05d', catalog_num);

                event_message = sprintf('Converted catalog number %d to string "%s".', ...
                    catalog_num, catalog_num_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from catalog number %d, returning empty string.', ...
            %         catalog_num);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function[classification_char, function_events] = generateClassificationString(obj)
            classification_char = '';
            function_events = ConsoleEvent.empty;

            % try
                % Admittedly a pretty pedantic function
                classification = obj.Classification;
                classification_char = classification;%sprintf('%s', classification);

                event_message = sprintf('Converted classification %s to string "%s".', ...
                    classification, classification_char);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from classification %s, returning empty string.', ...
            %         classification);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [launch_year_str, function_events] = generateLaunchYearString(obj)
            launch_year_str = '';
            function_events = ConsoleEvent.empty;

            % try
                launch_year = obj.LaunchYearDesignator;
                if isempty(launch_year)
                    launch_year_str = blanks(2);
                else
                    launch_year_str = sprintf('%02d', launch_year);
                end

                event_message = sprintf('Converted launch year %d to string "%s".', ...
                    launch_year, launch_year_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from launch year %d, returning empty string.', ...
            %         launch_year);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [launch_num_str, function_events] = generateLaunchNumString(obj)
            launch_num_str = '';
            function_events = ConsoleEvent.empty;

            % try
                launch_num = obj.LaunchNumberDesignator;
                if isempty(launch_num)
                    launch_num_str = blanks(3);
                else
                    launch_num_str = sprintf('%03d', launch_num);
                end

                event_message = sprintf('Converted launch number %d to string "%s".', ...
                    launch_num, launch_num_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from launch number %d, returning empty string.', ...
            %         launch_num);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [launch_piece_str, function_events] = generateLaunchPieceString(obj)
            launch_piece_str = '';
            function_events = ConsoleEvent.empty;

            % try
                launch_piece = obj.LaunchPieceDesignator;
                % if isempty(launch_piece)
                %     launch_piece_str = blanks(3);
                % else
                    launch_piece_str = pad(upper(launch_piece), 3);  % works with empty strings
                % end

                event_message = sprintf('Converted launch number %s to string "%s".', ...
                    launch_piece, launch_piece_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from launch piece %s, returning empty string.', ...
            %         launch_piece);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [epoch_year_str, function_events] = generateEpochYearString(obj)
            epoch_year_str = '';
            function_events = ConsoleEvent.empty;

            % try
                epoch_year = obj.EpochYear;
                % Convert to last two digits only
                epoch_year_abbr = mod(epoch_year, 100);
                epoch_year_str = sprintf('%02d', epoch_year_abbr);

                event_message = sprintf('Converted epoch year %d to string "%s".', ...
                    epoch_year, epoch_year_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from epoch year %d, returning empty string.', ...
            %         epoch_year);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [epoch_day_str, function_events] = generateEpochDayString(obj)
            epoch_day_str = '';
            function_events = ConsoleEvent.empty;

            % try
                epoch_day = obj.EpochDay;
                epoch_day_str = sprintf('%012.8f', epoch_day);

                event_message = sprintf('Converted epoch day %f to string "%s".', ...
                    epoch_day, epoch_day_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from epoch day %f, returning empty string.', ...
            %         epoch_day);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [first_deriv_str, function_events] = generateFirstDerivString(obj)
            first_deriv_str = '';
            function_events = ConsoleEvent.empty;

            % try
                first_deriv = obj.FirstDerivofMeanMotion;
                first_deriv_str = sprintf('% 9.8f', abs(first_deriv));
                % Remove leading 0 before decimal point
                chars_to_remove = 2;  % '0'
                first_deriv_str(chars_to_remove) = [];

                event_message = sprintf('Converted first derivative of mean motion %f to string "%s".', ...
                    first_deriv, first_deriv_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from first derivative of mean motion %f, returning empty string.', ...
            %         first_deriv);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [second_deriv_str, function_events] = generateSecondDerivString(obj)
            second_deriv_str = '';
            function_events = ConsoleEvent.empty;

            % try
                second_deriv = obj.SecondDerivofMeanMotion;
                % Convert format to FORTRAN sci notation
                second_deriv_str = sprintf('% .4e', second_deriv*10);  % note *10 to get correct FORTRAN format, which assumes base is 0 to 1
                % Remove 'e', decimal point, and first character in
                % exponent
                chars_to_remove = [3, 8, 10];  % '.', 'e', and '0'
                second_deriv_str(chars_to_remove) = [];

                event_message = sprintf('Converted second derivative of mean motion %f to string "%s".', ...
                    second_deriv, second_deriv_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from second derivative of mean motion %f, returning empty string.', ...
            %         second_deriv);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [b_star_str, function_events] = generateBStarString(obj)
            b_star_str = '';
            function_events = ConsoleEvent.empty;

            % try
                b_star = obj.BStar;
                % Convert format to FORTRAN sci notation
                b_star_str = sprintf('% .4e', b_star*10);  % note *10 to get correct FORTRAN format, which assumes base is 0 to 1
                % Remove 'e', decimal point, and first character in
                % exponent
                chars_to_remove = [3, 8, 10];  % '.', 'e', and '0'
                b_star_str(chars_to_remove) = [];

                event_message = sprintf('Converted ballistic coefficient B* %f to string "%s".', ...
                    b_star, b_star_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from ballistic coefficient B* %f, returning empty string.', ...
            %         b_star);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [ephemeris_type_str, function_events] = generateEphemerisTypeString(obj)
            ephemeris_type_str = '';
            function_events = ConsoleEvent.empty;

            % try
                ephem_type = obj.EphemerisType;
                ephemeris_type_str = upper(ephem_type);

                event_message = sprintf('Converted epehemris type "%s" to string "%s".', ...
                    ephem_type, ephemeris_type_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from ephemeris type "%s", returning empty string.', ...
            %         ephem_type);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [element_num_str, function_events] = generateElementNumString(obj)
            element_num_str = '';
            function_events = ConsoleEvent.empty;

            % try
                element_num = obj.ElementSetNum;
                element_num_str = sprintf('%4d', element_num);  % I have no idea why this number is given 4 digits but seems to be capped at 999
                event_message = sprintf('Converted element set number %d to string "%s".', ...
                    element_num, element_num_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from element set number %d, returning empty string.', ...
            %         element_num);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [checksum_str, function_events] = generateChecksumString(obj, line_num)
            checksum_str = '';
            function_events = ConsoleEvent.empty;

            % try
                if line_num == 1
                    checksum = obj.ChecksumOne;
                elseif line_num == 2
                    checksum = obj.ChecksumTwo;
                else
                    event_message = sprintf('Must specify line 1 or 2 for checksum, not %f. Returning empty string.', ...
                        line_num);
                    event_error_code = StatusCode.Error;
                    new_event = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_event];
                    throw(error(' '))  % TODO: temp fix till I stop being dumb
                end

                checksum_str = sprintf('%d', checksum);
                event_message = sprintf('Converted checksum %d to string "%s".', ...
                    checksum, checksum_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from checksum %d, returning empty string.', ...
            %         checksum);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [inclination_str, function_events] = generateInclinationString(obj)
            inclination_str = '';
            function_events = ConsoleEvent.empty;

            % try
                inclination = obj.Inclination;
                inclination_str = sprintf('%8.4f', inclination);
                event_message = sprintf('Converted inclination %f to string "%s".', ...
                    inclination, inclination_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from inclination %f, returning empty string.', ...
            %         inclination);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [raan_str, function_events] = generateRAANString(obj)
            raan_str = '';
            function_events = ConsoleEvent.empty;

            % try
                raan = obj.RAAN;
                raan_str = sprintf('%8.4f', raan);
                event_message = sprintf('Converted right ascension of ascending node %f to string "%s".', ...
                    raan, raan_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from right ascension of ascending node %f, returning empty string.', ...
            %         raan);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [eccentricity_str, function_events] = generateEccentricityString(obj)
            eccentricity_str = '';
            function_events = ConsoleEvent.empty;

            % try
                eccentricity = obj.Eccentricity;
                eccentricity_str = sprintf('%.7f', eccentricity);
                % Remove leading 0 and decimal point
                chars_to_remove = [1, 2];  % '0' and '.'
                eccentricity_str(chars_to_remove) = [];
                event_message = sprintf('Converted eccentricity %f to string "%s".', ...
                    eccentricity, eccentricity_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from eccentricity %f, returning empty string.', ...
            %         eccentricity);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [arg_of_periapsis_str, function_events] = generateArgOfPeriapsisString(obj)
            arg_of_periapsis_str = '';
            function_events = ConsoleEvent.empty;

            % try
                arg_of_periapsis = obj.ArgumentOfPeriapsis;
                arg_of_periapsis_str = sprintf('%8.4f', arg_of_periapsis);
                event_message = sprintf('Converted argument of periapsis %f to string "%s".', ...
                    arg_of_periapsis, arg_of_periapsis_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from argument of periapsis %f, returning empty string.', ...
            %         arg_of_periapsis);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [mean_anomaly_str, function_events] = generateMeanAnomalyString(obj)
            mean_anomaly_str = '';
            function_events = ConsoleEvent.empty;

            % try
                mean_anomaly = obj.MeanAnomaly;
                mean_anomaly_str = sprintf('%8.4f', mean_anomaly);
                event_message = sprintf('Converted mean anomaly %f to string "%s".', ...
                    mean_anomaly, mean_anomaly_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from mean anomaly %f, returning empty string.', ...
            %         mean_anomaly);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [mean_motion_str, function_events] = generateMeanMotionString(obj)
            mean_motion_str = '';
            function_events = ConsoleEvent.empty;

            % try
                mean_motion = obj.MeanMotion;
                mean_motion_str = sprintf('%11.8f', mean_motion);
                event_message = sprintf('Converted mean motion %f to string "%s".', ...
                    mean_motion, mean_motion_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from mean motion %f, returning empty string.', ...
            %         mean_motion);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        function [rev_num_str, function_events] = generateRevNumString(obj)
            rev_num_str = '';
            function_events = ConsoleEvent.empty;

            % try
                rev_num = obj.RevolutionNoAtEpoch;
                rev_num_str = sprintf('%5d', rev_num);
                event_message = sprintf('Converted revolution at epoch %d to string "%s".', ...
                    rev_num, rev_num_str);
                new_message = ConsoleEvent(event_message);
                function_events = [function_events, new_message];

            % catch e
            %     event_message = sprintf('Unable to generate string from revolution at epoch %d, returning empty string.', ...
            %         rev_num);
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % end
        end

        % function obj = set.TLELine1(obj, line_str)
        % 
        %     % Check if the inputted line has a valid format before setting
        %     line_is_valid = obj.validateLine1Format(line_str);
        %     if line_is_valid
        %         obj.TLELine1 = line_str;
        %     else
        %         % warning("Unable to set Line 1 of a TLE ")
        %     end
        % end
        % 
        % function obj = set.TLELine2(obj, line_str)
        % 
        %     % Check if the inputted line has a valid format before setting
        %     line_is_valid = obj.validateLine2Format(line_str);
        %     if line_is_valid
        %         obj.TLELine2 = line_str;
        %     else
        %         % warning("Unable to process a TLE")
        %     end
        % end

        % function value = get.Checksum1Valid(obj)
        %     % If both lines are empty -> checksum = 0
        %     % If ignore checksums is checked -> checksum = 1
        %     % Otherwise, run the function and check validity of checksum
        %     if isempty(obj.TLELine1) || isempty(obj.TLELine2)
        %         value = false;
        %     elseif obj.IgnoreChecksums && ~isempty(obj.TLELine1) && ~isempty(obj.TLELine2)
        %         value = true;
        %     else
        %         % Calculate checksum
        %         checksum_1_is_valid = obj.calculateChecksum(obj.TLELine1);
        %         checksum_2_is_valid = obj.calculateChecksum(obj.TLELine2);
        %         if checksum_1_is_valid && checksum_2_is_valid
        %             value = true;
        %         end
        %         if ~checksum_1_is_valid
        %             % warning("The checksum of Line 1 is invalid, the data in the TLE might have been lost.")
        %             value = false;
        %         end
        %         if ~checksum_2_is_valid
        %             % warning("The checksum of Line 2 is invalid, the data in the TLE might have been lost.")
        %             value = false;
        %         end
        %     end
        % end

        % function isvalid = get.FormatValid(obj)
        %     % If both lines are empty -> formats aren't valid
        %     % Otherwise -> formats are valid
        %     if isempty(obj.TLELine1) || isempty(obj.TLELine2)
        %         isvalid = false;
        %     else
        %         isvalid = true;
        %     end
        % end

        % function is_valid = validateLine1Format(~, line)
        %     is_valid = true;
        % 
        %     %% Basic length and format check
        %     TLE_length = 69;
        %     TLE_input_length = strlength(line);
        %     first_character = str2double(line(1));
        % 
        %     if TLE_input_length ~= TLE_length
        %         warning('Line 1 has incorrect length')
        %         is_valid = false;
        %         return
        %     end
        %     if first_character ~= 1
        %         warning("Line 1 does not start with the number 1")
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for required empty columns
        %     empty_space_columns = [2, 9, 18, 33, 44, 53, 62, 64];
        %     num_empty_spaces = length(empty_space_columns);
        % 
        %     for i = 1:num_empty_spaces
        %         if ~isspace(line(empty_space_columns(i)))
        %             warning("Column %d in Line 1 is not empty.", empty_space_columns(i))
        %             warning("Unable to load the TLE with Line 1: '%s'", line)
        %             is_valid = false;
        %             return
        %         end
        %     end
        % 
        %     %% Check for satellite catalog number
        %     sat_num_columns = 3:7;
        %     num_sat_num_columns = length(sat_num_columns);
        % 
        %     for i = 1:num_sat_num_columns
        %         if ~isstrprop(line(sat_num_columns(i)), "digit") || isempty(line(sat_num_columns(i)))
        %             warning("The satellite catalog number must contain numbers and cannot be empty. Columns 3 through 7, Line 1.")
        %             warning("Unable to load the TLE with Line 1: '%s'", line)
        %             is_valid = false;
        %             return
        %         end
        %     end
        % 
        %     %% Check for classification
        %     class_column = 8;
        % 
        %     if line(class_column) == 'U' || line(class_column) == 'C' || line(class_column) == 'S'
        %     else
        %         warning("Unrecognized classification of satellite. Column 8, Line 1.")
        %         warning("Unable to load the TLE with Line 1: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for international designators
        %     intl_designator_yr_columns = 10:11;
        %     intl_designator_num_columns = 12:14;
        %     intl_designator_piece_columns = 15:17;
        % 
        %     % Check existance of fields
        %     intl_designator_yr_exists = any(~isspace(line(intl_designator_yr_columns)));
        %     intl_designator_num_exists = any(~isspace(line(intl_designator_num_columns)));
        %     intl_designator_piece_exists = any(~isspace(line(intl_designator_piece_columns)));
        % 
        %     % Manage bad inputs
        %     wrong_input_yr = any(~isstrprop(line(intl_designator_yr_columns), "digit"));
        %     wrong_input_num = any(~isstrprop(line(intl_designator_num_columns), "digit"));
        %     wrong_input_piece = any(isstrprop(line(intl_designator_piece_columns), "punct")) || ...
        %         any(isstrprop(line(intl_designator_piece_columns), "digit")) || ...
        %         all(isstrprop(line(intl_designator_piece_columns), "wspace"));
        % 
        %     % If one exists, the others cannot be empty
        %     if intl_designator_yr_exists || intl_designator_num_exists || intl_designator_piece_exists
        %         if wrong_input_yr
        %             warning("The launch year must be a numerical value and cannot be empty. Columns 10 through 11, Line 1.")
        %             warning("Unable to load the TLE with Line 1: '%s'", line)
        %             is_valid = false;
        %             return
        %         end
        %         if wrong_input_num
        %             warning("The launch number of the year must be a numerical value and cannot be empty. Columns 12 through 14, Line 1.")
        %             warning("Unable to load the TLE with Line 1: '%s'", line)
        %             is_valid = false;
        %             return
        %         end
        %         if wrong_input_piece
        %             warning("The piece of the launch must contain letters and cannot be empty. Columns 15 through 17, Line 1.")
        %             warning("Unable to load the TLE with Line 1: '%s'", line)
        %             is_valid = false;
        %             return
        %         end
        %     end
        % 
        %     %% Check for Epoch entries
        %     epoch_yr_columns = 19:20;
        %     epoch_day_columns = 21:32;
        % 
        %     % Manage bad inputs
        %     wrong_input_epoch_yr = any(~isstrprop(line(epoch_yr_columns), "digit"));
        %     wrong_input_epoch_day = ~isfloat(str2double(line(epoch_day_columns)));
        % 
        %     if wrong_input_epoch_yr
        %         warning("The Epoch year must be a numerical value. Columns 19 through 20, Line 1.")
        %         warning("Unable to load the TLE with Line 1: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        %     if wrong_input_epoch_day
        %         warning("The Epoch day must be a numerical value. Columns 21 through 32, Line 1.")
        %         warning("Unable to load the TLE with Line 1: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for Derivative of Motion
        %     first_derivative_columns = 34:43;
        %     second_derivative_columns = 45:52;
        % 
        %     % Managed bad inputs
        %     wrong_input_first_d = ~isfloat(str2double(line(first_derivative_columns))) || ...
        %         isnan(str2double(line(first_derivative_columns)));
        %     wrong_input_second_d = any(isstrprop(line(second_derivative_columns), "alpha")); % Multiple formats to keep track of
        % 
        %     if wrong_input_first_d
        %         warning("The first derivative of mean motion must be a single numerical value. Columns 34 through 43, Line 1.")
        %         warning("Unable to load the TLE with Line 1: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        %     if wrong_input_second_d
        %         warning("The second derivative of mean motion cannot include letters. Columns 45 through 52, Line 1.")
        %         warning("Unable to load the TLE with Line 1: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for Drag Term
        %     drag_term_columns = 54:61;
        % 
        %     % Manage bad inputs
        %     wrong_input_drag = any(isstrprop(line(drag_term_columns), "alpha"));
        % 
        %     if wrong_input_drag
        %         warning("The drag term cannot include letters. Columns 54 through 61, Line 1.")
        %         warning("Unable to load the TLE with Line 1: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for Ephemeris Type
        %     ephemeris_type_column = 63;
        % 
        %     % Manage bad inputs
        %     wrong_input_ephemeris = str2double(line(ephemeris_type_column)) ~= 0;
        % 
        %     if wrong_input_ephemeris
        %         warning("The ephemeris type must be 0. Column 63, Line 1.")
        %         warning("Unable to load the TLE with Line 1: '%s", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for Element Set Number
        %     element_set_num_columns = 65:68;
        % 
        %     % Manage bad inputs
        %     wrong_input_element = ~isfloat(str2double(line(element_set_num_columns))) || ...
        %         isnan(str2double(line(element_set_num_columns)));
        % 
        %     if wrong_input_element
        %         warning("The element set number must be a numerical value. Column 65 through 68, Line 1.")
        %         warning("Unable to load the TLE with Line 1: '%s", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Chek for checksum
        %     checksum = str2double(line(end));
        % 
        %     % Verify extracted checksum
        %     if ~isfloat(checksum) || isnan(checksum)
        %         warning("The checksum must be a numerical value. Column 69, Line 1 of TLE with Line 1: '%s'", line)
        %         return
        %     end
        % end
        % 
        % % Done?
        % function is_valid = validateLine2Format(~, line)
        %     % TODO: port/rewrite from current app's validate_TLE function
        %     is_valid = true;
        % 
        %     %% Basic length and format check
        %     TLE_length = 69;
        %     TLE_input_length = strlength(line);
        %     first_character = str2double(line(1));
        % 
        %     if TLE_input_length ~= TLE_length
        %         warning('Line 2 has incorrect length')
        %         is_valid = false;
        %         return
        %     end
        %     if first_character ~= 2
        %         warning("Line 2 does not start with the number 2")
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for required empty columns
        %     empty_space_columns = [2, 8, 17, 26, 34, 43, 52];
        %     num_empty_spaces = length(empty_space_columns);
        % 
        %     for i = 1:num_empty_spaces
        %         if ~isspace(line(empty_space_columns(i)))
        %             warning("Column %d in Line 2 is not empty.", empty_space_columns(i))
        %             warning("Unable to load the TLE with Line 2: '%s'", line)
        %             is_valid = false;
        %             return
        %         end
        %     end
        % 
        %     %% Check for satellite catalog number
        %     sat_num_columns = 3:7;
        %     num_sat_num_columns = length(sat_num_columns);
        % 
        %     for i = 1:num_sat_num_columns
        %         if ~isstrprop(line(sat_num_columns(i)), "digit") || isempty(line(sat_num_columns(i)))
        %             warning("The satellite catalog number must contain numbers and cannot be empty. Columns 3 through 7, Line 2.")
        %             warning("Unable to load the TLE with Line 2: '%s'", line)
        %             is_valid = false;
        %             return
        %         end
        %     end
        % 
        %     %% Check for inclination
        %     inclination_columns = 9:16;
        % 
        %     % Manage bad inputs
        %     wrong_input_inclination = ~isfloat(str2double(line(inclination_columns))) || ...
        %         isnan(str2double(line(inclination_columns)));
        % 
        %     if wrong_input_inclination
        %         warning("The inclination must be a numerical value. Columns 9 through 16, Line 2.")
        %         warning("Unable to load the TLE with Line 2: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for RAAN
        %     raan_columns = 18:25;
        % 
        %     % Manage bad inputs
        %     wrong_input_raan = ~isfloat(str2double(line(raan_columns))) || ...
        %         isnan(str2double(line(raan_columns)));
        % 
        %     if wrong_input_raan
        %         warning("The right ascension of the ascending node must be a numerical value. Columns 18 through 25, Line 2.")
        %         warning("Unable to load the TLE with Line 2: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for Eccentricity
        %     ecc_columns = 27:33;
        % 
        %     % Manage bad inputs
        %     wrong_input_ecc = ~isfloat(str2double(line(ecc_columns))) || ...
        %         isnan(str2double(line(ecc_columns)));
        % 
        %     if wrong_input_ecc
        %         warning("The eccentricity must be a numerical value. Columns 27 through 33, Line 2.")
        %         warning("Unable to load the TLE with Line 2: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for Argument of Perigee
        %     arg_perigee_columns = 35:42;
        % 
        %     % Manage bad inputs
        %     wrong_input_arg_perigee = ~isfloat(str2double(line(arg_perigee_columns))) || ...
        %         isnan(str2double(line(arg_perigee_columns)));
        % 
        %     if wrong_input_arg_perigee
        %         warning("The argument of perigee must be a numerical value. Columns 35 through 42, Line 2.")
        %         warning("Unable to load the TLE with Line 2: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for Mean Anomaly
        %     mean_anomaly_columns = 44:51;
        % 
        %     % Manage bad inputs
        %     wrong_input_mean_anomaly = ~isfloat(str2double(line(mean_anomaly_columns))) || ...
        %         isnan(str2double(line(mean_anomaly_columns)));
        % 
        %     if wrong_input_mean_anomaly
        %         warning("The mean anomaly must be a numerical value. Columns 44 through 51, Line 2.")
        %         warning("Unable to load the TLE with Line 2: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for Mean Motion
        %     mean_motion_columns = 53:63;
        % 
        %     % Manage bad inputs
        %     wrong_input_mean_motion = ~isfloat(str2double(line(mean_motion_columns))) || ...
        %         isnan(str2double(line(mean_motion_columns)));
        % 
        %     if wrong_input_mean_motion
        %         warning("The mean motion must be a numerical value. Columns 53 through 63, Line 2.")
        %         warning("Unable to load the TLE with Line 2: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Check for Revolution Number at Epoch
        %     rev_num_epoch_columns = 64:68;
        % 
        %     % Manage bad inputs
        %     wrong_input_rev_num = ~isfloat(str2double(line(rev_num_epoch_columns))) || ...
        %         isnan(str2double(line(rev_num_epoch_columns)));
        % 
        %     if wrong_input_rev_num
        %         warning("The revolution number at epoch must be a numerical value. Columns 64 through 68, Line 2.")
        %         warning("Unable to load the TLE with Line 2: '%s'", line)
        %         is_valid = false;
        %         return
        %     end
        % 
        %     %% Chek for checksum
        %     checksum = str2double(line(end));
        % 
        %     % Verify extracted checksum
        %     if ~isfloat(checksum) || isnan(checksum)
        %         warning("The checksum must be a numerical value. Column 69, Line 2 of TLE with Line 2: %s", line)
        %         return
        %     end
        % end

        % Checksum
        function checksum_calc = calculateChecksum(~, TLE_line)

            % Remove the last character, which is the checksum character
            TLE_line = TLE_line(1:end-1);

            % Replace '-' with 1
            TLE_line(TLE_line == '-') = '1';

            % Convert non-numeric characters to 0
            TLE_line(~isstrprop(TLE_line, 'digit')) = '0';

            % Convert the remaining characters to doubles and sum them up
            checksum_calc = 0;

            for i = 1:strlength(TLE_line)
                checksum_calc = checksum_calc + str2double(TLE_line(i));
            end

            % Take the mod 10 of the checksum
            checksum_calc = mod(checksum_calc, 10);

        end

        function obj = validateChecksums(obj)

            % Line 1
            TLE_line = obj.TLELine1;
            checksum = obj.ChecksumOne;
            checksum_calc = obj.calculateChecksum(TLE_line);

            % Compare and check
            checksum_is_valid = checksum == checksum_calc;
            
            obj.Checksum1Valid = checksum_is_valid;
            
            % Line 2
            TLE_line = obj.TLELine2;
            checksum = obj.ChecksumTwo;
            checksum_calc = obj.calculateChecksum(TLE_line);

            % Compare and check
            checksum_is_valid = checksum == checksum_calc;
            
            obj.Checksum2Valid = checksum_is_valid;
            
        end

        function obj = generateChecksums(obj)

            % Line 1
            TLE_line = obj.TLELine1;
            checksum = obj.calculateChecksum(TLE_line);
            obj.ChecksumOne = checksum;
            
            % Line 2
            TLE_line = obj.TLELine2;
            checksum = obj.calculateChecksum(TLE_line);
            obj.ChecksumTwo = checksum;
        end
            

        % Assign variables to object from Line
        function obj = assignVariablesFromStoredTLELines(obj)
            % TODO: port/rewrite

            % % Check if currently stored TLE format is valid
            % if obj.FormatValid
                % Line 1
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
                obj.MeanMotion = str2double(obj.TLELine2(53:63));
                obj.RevolutionNoAtEpoch = str2double(obj.TLELine2(64:68));
                obj.ChecksumTwo = str2double(obj.TLELine2(69));

                % Get checksum
                obj.Checksum1Valid;
            % end
        end

        function [obj, function_events] = generateTLELinesFromStoredVariables(obj, autogenerate_checksums)
            if nargin < 2
                autogenerate_checksums = false;
            end
            
            function_events = ConsoleEvent.empty;
            % line_1_str = '';
            % line_2_str = '';

            % try 
                % Build line 1
                line_num_char = '1';

                [cat_num_str, ~] = obj.generateCatalogNumString();

                [classification_char, ~] = obj.generateClassificationString();

                [launch_yr_str, ~] = obj.generateLaunchYearString();

                [launch_num_str, ~] = obj.generateLaunchNumString();

                [launch_piece_str, ~] = obj.generateLaunchPieceString();

                [epoch_year_str, ~] = obj.generateEpochYearString();

                [epoch_day_str, ~] = obj.generateEpochDayString();

                [first_deriv_str, ~] = obj.generateFirstDerivString();

                [second_deriv_str, ~] = obj.generateSecondDerivString();

                [b_star_str, ~] = obj.generateBStarString();

                [ephemeris_char, ~] = obj.generateEphemerisTypeString();

                [element_num_str, ~] = obj.generateElementNumString();

                [checksum_str, ~] = obj.generateChecksumString(1);


                line_1_str = [line_num_char, blanks(1), ...
                    cat_num_str, classification_char, blanks(1), ...
                    launch_yr_str, launch_num_str, launch_piece_str, blanks(1), ...
                    epoch_year_str, epoch_day_str, blanks(1), ...
                    first_deriv_str, blanks(1), ...
                    second_deriv_str, blanks(1), ...
                    b_star_str, blanks(1), ...
                    ephemeris_char, blanks(1), ...
                    element_num_str, checksum_str];

                % Build line 2
                line_num_char = '2';
                [inclination_str, ~] = obj.generateInclinationString();
                
                [raan_str, ~] = obj.generateRAANString();
                
                [eccentricity_str, ~] = obj.generateEccentricityString();
                
                [arg_of_periapsis_str, ~] = obj.generateArgOfPeriapsisString();
                
                [mean_anomaly_str, ~] = obj.generateMeanAnomalyString();
                
                [mean_motion_str, ~] = obj.generateMeanMotionString();
                
                [rev_num_str, ~] = obj.generateRevNumString();
                
                [checksum_str, ~] = obj.generateChecksumString(2);
                

                line_2_str = [line_num_char, blanks(1), ...
                    cat_num_str, blanks(1), ...
                    inclination_str, blanks(1), ...
                    raan_str, blanks(1), ...
                    eccentricity_str, blanks(1), ...
                    arg_of_periapsis_str, blanks(1), ...
                    mean_anomaly_str, blanks(1), ...
                    mean_motion_str, rev_num_str, checksum_str];
                

            % catch e
            % 
            %     event_message = sprintf('Unable to generate TLE lines from stored variables. TLE lines not assigned.');
            %     event_error_code = StatusCode.Error;
            %     new_event = ConsoleEvent(event_message, event_error_code, e);
            %     function_events = [function_events, new_event];
            %     return
            % 
            % end

            % Assign variables
            obj.TLELine1 = line_1_str;
            obj.TLELine2 = line_2_str;

            if autogenerate_checksums
                obj = obj.generateChecksums();
                [checksum1_str, ~] = obj.generateChecksumString(1);
                [checksum2_str, ~] = obj.generateChecksumString(2);
                obj.TLELine1(end) = checksum1_str;
                obj.TLELine2(end) = checksum2_str;
            end
            obj = obj.validateChecksums();

        end

    end
end
