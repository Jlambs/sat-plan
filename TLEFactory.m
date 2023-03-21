classdef TLEFactory < handle
    % TLEFACTORY A helper factory for easily generating TLE objects from
    % different sources.
    %   Detailed explanation goes here
    
    methods

        function [new_TLE_object, is_valid] = createTLEFromFile(obj, file_name)

            % TODO: allow searching from a file with multiple TLEs to only
            % load the specified satellite names and/or catalog numbers.
            % See find_TLE function from original app, though that function
            % could certainly use a rewrite!!

            TLE_raw_text = fileread(file_name);
            TLE_strings = splitlines(TLE_raw_text);
            satellite_name = TLE_strings{1};  % TODO: handle cases where no name line is given
            line_1 = TLE_strings{2};
            line_2 = TLE_strings{3};
            new_TLE_object = TLE();
            new_TLE_object.SatelliteName = satellite_name;
            new_TLE_object.TLELine1 = line_1;
            new_TLE_object.TLELine2 = line_2;
            % TODO: the parameter FormatValid doesn't seem to be getting
            % set by the call to set.TLELine1, possibly need to change TLE
            % to handle class?
            is_valid = true;%new_TLE_object.FormatValid;  % not sure if you actually need to return this, or just check it later

        end

        function [new_TLE_object, is_valid] = createTLEFromURL(obj, url_string)%, name_or_catalog_num)
            % TODO: allow searching from a file with multiple TLEs to only
            % load the specified satellite names and/or catalog numbers.
            % See find_TLE function from original app, though that function
            % could certainly use a rewrite!!

            TLE_raw_text = webread(url_string);
            TLE_strings = splitlines(TLE_raw_text);
            satellite_name = TLE_strings{1};  % TODO: handle cases where no name line is given
            line_1 = TLE_strings{2};
            line_2 = TLE_strings{3};
            new_TLE_object = TLE();
            new_TLE_object.SatelliteName = satellite_name;
            new_TLE_object.TLELine1 = line_1;
            new_TLE_object.TLELine2 = line_2;
            is_valid = new_TLE_object.FormatValid;  % not sure if you actually need to return this, or just check it later
        end

        function [new_TLE_object, is_valid] = createTLEFromKeplerianElements(obj, satellite_name, semi_major_axis, eccentricity, inclination, RAAN, arg_of_periapsis, true_anomaly)
            % TODO: allow creating multiple TLE objects if inputs are
            % vectors
           
            new_TLE_object = TLE();
            new_TLE_object.SatelliteName = satellite_name;
            new_TLE_object.SemiMajorAxis = semi_major_axis;
            new_TLE_object.Eccentricity = eccentricity;
            new_TLE_object.Inclination = inclination;
            new_TLE_object.RAAN = RAAN;
            new_TLE_object.ArgumentOfPeriapsis = arg_of_periapsis;
            new_TLE_object.TrueAnomaly = true_anomaly;

            is_valid = new_TLE_object.FormatValid;  % not sure if you actually need to return this, or just check it later
        
        end

        % See https://www.mathworks.com/help/satcom/ref/matlabshared.satellitescenario.satellite.orbitalelements.html
        function [new_TLE_object, is_valid] = createTLEFromSGP4Elements(obj, satellite_name, semi_major_axis, eccentricity, inclination, RAAN, arg_of_periapsis, mean_anomaly, epoch, B_star, mean_orbital_period)

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

