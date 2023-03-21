classdef TLE %< handle  % TODO: figure out if this is best defined as a value class or handle class, see https://www.mathworks.com/help/matlab/matlab_oop/which-kind-of-class-to-use.html
    % TLE Object that defines a single Two-Line-Element (TLE) set, which
    % defines the orbital properties of a satellite.
    %   Detailed explanation goes here
    
    properties
        SatelliteName char = ''

        TLELine1 char = ''
        TLELine2 char = ''

        FormatValid logical = false  % TODO: should be read-only
        ChecksumValid logical = false  % TODO: should be read-only

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
        BStar double = 0
        MeanOrbitalPeriod double = 0
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

                % TODO: figure out when and where is best to do this
                obj.validateStoredTLE();
                % if obj.FormatValid
                %     obj.assignVariablesFromStoredTLELines();
                % end
            end

        end

        % TODO: some helper functions that can interact with both lines at
        % once might be nice to have
        function obj = set.TLELine2(obj, line_str)

            obj.TLELine2 = line_str;

            % TODO: figure out when and where is best to do this
            obj.validateStoredTLE();

        end

        function obj = validateStoredTLE(obj)
            % TODO: decide how to best structure this process. For example,
            % if the format is invalid, is it even worth calculating the
            % checksum, or will doing that just create more errors?
            obj.FormatValid = true;
            obj.ChecksumValid = true;
        end

        function is_valid = validateStoredVariables(obj)
            % TODO: decide how to best structure this process. For example,
            % if the format is invalid, is it even worth calculating the
            % checksum, or will doing that just create more errors?
            is_valid = true;
        end

        function is_valid = validateLine1Format(obj, line_1_text)
            % TODO: port/rewrite from current app's validate_TLE function
            is_valid = true;
        end

        function is_valid = validateChecksum(obj, line_text)
            % TODO: port/rewrite from current app's validate_TLE function
            is_valid = true;
        end

        function assignVariablesFromStoredTLELines(obj)
            % TODO: port/rewrite

            % Check if currently stored TLE format is valid
            if obj.FormatValid
                
                % Extract orbital information from TLE
                % TODO

            end
        end

        function obj = generateTLELinesFromStoredVariables(obj)
            % TODO
            obj.TLELine1 = 'line 1 text';
            obj.TLELine2 = 'line 2 text';
        end

    end
end

