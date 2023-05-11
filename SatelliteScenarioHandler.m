classdef SatelliteScenarioHandler < handle
    % SATELLITEPROPERTIES Houses and controls the satelliteScenario object,
    % as well as satellites added to it.
    %    Detailed explanation goes here
    
    properties
        % TODO: better access types for these
        SatelliteScenario(1,1) satelliteScenario = satelliteScenario()
        ScenarioStartDatetime(1,1) datetime  
        ScenarioEndDatetime(1,1) datetime
        ScenarioTimestepSizeSec(1,1) double

        Satellites(1,:)  % no validation for Satellite type, unfortunately
        GroundStations(1,:)
    end

    properties (Access = private, Constant)
        DefaultAltitude(1,1) double = 0
        DefaultMinElevationAngle(1,1) double = 0
    end
    
    methods
        % function obj = SatelliteScenarioHandler(sat_scenario)
        %     % SATELLITESCENARIOHANDLER Construct an instance of this class
        %     %   Detailed explanation goes here
        %     obj.SatelliteScenario = sat_scenario;
        % end
        
        function function_events = addSatelliteFromTLEFile(obj, tle_file_name)
            function_events = ConsoleEvent.empty;

            try
                new_satellites = satellite(obj.SatelliteScenario, tle_file_name);
                num_new_satellites = length(new_satellites);
                if num_new_satellites > 0
                        obj.Satellites = [obj.Satellites, new_satellites];
                else
                    event_message = sprintf('No TLEs found to add to satellite scenario in file %s. Skipping adding satellites.', ...
                        tle_file_name);
                    event_error_code = StatusCode.Warning;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];
                    return
                end
                
                event_message = sprintf('Added %d TLEs to satellite scenario from file %s.', ...
                    num_new_satellites, tle_file_name);
                new_events = ConsoleEvent(event_message);
                function_events = [function_events, new_events];

            catch e
                event_message = sprintf('Unable to add TLEs to satellite scenario from file %s. Skipping adding satellites.', ...
                    tle_file_name);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                % return
            end
        end
        
        function function_events = addGroundStation(obj, gs_name, gs_lat, gs_long, gs_alt, min_elevation)
            function_events = ConsoleEvent.empty;

            if nargin > 5
                min_elevation = obj.DefaultMinElevationAngle;
            end
            if nargin > 4
                gs_alt = obj.DefaultAltitude;
            end

            try
                new_groundstation = groundStation(obj.SatelliteScenario, ...
                    'Name', gs_name, 'Latitude', gs_lat, 'Longitude', gs_long, ...
                    'Altitude', gs_alt, 'MinElevationAngle', min_elevation);

                obj.GroundStations{end+1} = new_groundstation;
                
                event_message = sprintf('Added ground station %s to satellite scenario.', ...
                    num_new_groundstations, tle_file_name);
                new_events = ConsoleEvent(event_message);
                function_events = [function_events, new_events];

            catch e
                event_message = sprintf('Unable to add ground station %s to satellite scenario. Skipping adding ground station.', ...
                    tle_file_name);
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
                % return
            end

            
        end

        function set.ScenarioStartDatetime(obj, new_datetime)
            % TODO: error checking
            obj.SatelliteScenario.StartTime = new_datetime;
            obj.ScenarioStartDatetime = new_datetime;
        end

        function set.ScenarioEndDatetime(obj, new_datetime)
            % TODO: error checking
            obj.SatelliteScenario.StopTime = new_datetime;
            obj.ScenarioEndDatetime = new_datetime;
        end

        function set.ScenarioTimestepSizeSec(obj, new_timestep_size)
            % TODO: error checking
            obj.SatelliteScenario.SampleTime = new_timestep_size;
            obj.ScenarioTimestepSizeSec = new_timestep_size;
        end

        function displayGraphics(obj)
            play(obj.SatelliteScenario);
        end

        function function_events = resetSatelliteScenario(obj)
            function_events = ConsoleEvent.empty;

            try

                % Clear out all stored variables
                obj.SatelliteScenario = [];
                obj.ScenarioStartDatetime = NaT;
                obj.ScenarioEndDatetime = NaT;
                obj.ScenarioTimestepSizeSec = [];
                obj.Satellites = [];
                obj.GroundStations = [];

                % Make a new satellite scenario
                obj.SatelliteScenario = satelliteScenario();
                
                event_message = sprintf('Reset satellite scenario. No satellites or ground stations added.');
                new_events = ConsoleEvent(event_message);
                function_events = [function_events, new_events];

            catch e
                event_message = sprintf('Unable to reset satellite scenario. Previous data may still be loaded.');
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
            end

        end

        function [table_data, function_events] = generatePropagationTableData(obj, satellite_idxs, coordinates, timestamp_format)
            if nargin < 4
                timestamp_format = 'yyyyMMddHHmmSS';  % TODO: make properties for default arguments
            end
            if nargin < 3
                coordinates = 'geographic';  % geographic give LLA
            end
            if nargin < 2
                total_num_satellites = length(obj.Satellites);
                satellite_idxs = 1:total_num_satellites;
            end

            function_events = ConsoleEvent.empty;
            table_data = table();

            try

                % Initialize table columns
                % TODO: other coordinate systems
                if strcmpi(coordinates, 'LLA') || strcmpi(coordinates, 'geographic')
                    
                    table_column_names = { ...
                        'Satellite ID', ...
                        'Satellite Name', ...
                        'Time', ...
                        'Latitude (deg)', ...
                        'Longitude (deg)', ...
                        'Altitude (m)', ...
                        'Velocity (x)', ...
                        'Velocity (y)', ...
                        'Velocity (z)'
                        };

                    coordinates = 'geographic';

                elseif strcmpi(coordinates, 'ECEF')
                        
                    table_column_names = { ...
                        'Satellite ID', ...
                        'Satellite Name', ...
                        'Time', ...
                        'Position (x)', ...
                        'Position (y)', ...
                        'Position (z)', ...
                        'Velocity (x)', ...
                        'Velocity (y)', ...
                        'Velocity (z)'
                        };

                elseif strcmpi(coordinates, 'GCRF') || strcmpi(coordinates, 'intertial')
                    table_column_names = { ...
                        'Satellite ID', ...
                        'Satellite Name', ...
                        'Time', ...
                        'Position (x)', ...
                        'Position (y)', ...
                        'Position (z)', ...
                        'Velocity (x)', ...
                        'Velocity (y)', ...
                        'Velocity (z)'
                        };

                        coordinates = 'intertial';

                else

                    event_message = sprintf('Unable to generate propagation table data from satellite scenario in coordinate system "%s". Must be "LLA"/"geographic", "ECEF", or "GCRF"/"intertial". Returning empty table.', ...
                        coordinates);
                    event_error_code = StatusCode.Error;
                    new_events = ConsoleEvent(event_message, event_error_code);
                    function_events = [function_events, new_events];

                end

                % Get satellite states
                satellites_to_show = obj.Satellites(satellite_idxs);
                [all_positions, all_velocities, all_times] = states(satellites_to_show, 'CoordinateFrame', coordinates);

                % Reformat to 4-by-m*n cell array, where m is the number of
                % satellites and n is the number of datapoints
                % FIXME: Could probably do this more cleanly with a well
                % formatted call to cell2mat. This is just blindly matching
                % the format found in TLEHandler's equivalent function
                num_satellites_to_show = length(satellite_idxs);
                num_timesteps = length(all_times);
                total_num_rows = num_timesteps * num_satellites_to_show;
                satellite_id_column_data = cell(total_num_rows, 1);
                satellite_name_column_data = cell(total_num_rows, 1);
                time_column_data = cell(total_num_rows, 1);
                pos_coord1_column_data = cell(total_num_rows, 1);
                pos_coord2_column_data = cell(total_num_rows, 1);
                pos_coord3_column_data = cell(total_num_rows, 1);
                vel_coord1_column_data = cell(total_num_rows, 1);
                vel_coord2_column_data = cell(total_num_rows, 1);
                vel_coord3_column_data = cell(total_num_rows, 1);
                
                for i = 1:num_satellites_to_show

                    current_satellite = obj.Satellites(i);
                    current_start_row = (i-1)*num_timesteps + 1;
                    current_end_row = i*num_timesteps;

                    satellite_id_column_data(current_start_row:current_end_row) = {i};
                    satellite_name_column_data(current_start_row:current_end_row) = {current_satellite.Name};
                    time_column_data(current_start_row:current_end_row) = num2cell(all_times);  % FIXME: convert this stuff outside of the loop
                    pos_coord1_column_data(current_start_row:current_end_row) = num2cell(all_positions(1, :, i));
                    pos_coord2_column_data(current_start_row:current_end_row) = num2cell(all_positions(2, :, i));
                    pos_coord3_column_data(current_start_row:current_end_row) = num2cell(all_positions(3, :, i));
                    vel_coord1_column_data(current_start_row:current_end_row) = num2cell(all_velocities(1, :, i));
                    vel_coord2_column_data(current_start_row:current_end_row) = num2cell(all_velocities(2, :, i));
                    vel_coord3_column_data(current_start_row:current_end_row) = num2cell(all_velocities(3, :, i));
                end

                % Build data cell
                % Order must match default column ordering!
                % { ...
                %     'Satellite ID', ...
                %     'Satellite Name', ...
                %     'Time', ...
                %     'Position Coord 1', ...
                %     'Position Coord 2', ...
                %     'Position Coord 3', ...
                %     'Velocity Coord 1', ...
                %     'Velocity Coord 2', ...
                %     'Velocity Coord 3', ...
                % }
                table_data_cell = [ ...
                    satellite_id_column_data, ...
                    satellite_name_column_data, ...
                    time_column_data, ...
                    pos_coord1_column_data, ...
                    pos_coord2_column_data, ...
                    pos_coord3_column_data, ...
                    vel_coord1_column_data, ...
                    vel_coord2_column_data, ...
                    vel_coord3_column_data];

                warning off  % FIXME: only disable specific type of warning
                table_data.Variables = table_data_cell;
                warning on
                table_data.Properties.VariableNames = table_column_names;

                event_message = sprintf('Generated propagation table data from %d stored satellites and %d timesteps.', ...
                    num_satellites_to_show, num_timesteps);
                new_events = ConsoleEvent(event_message);
                function_events = [function_events, new_events];

            catch e
                event_message = sprintf('Unable to generate propagation table data from satellite scenario. Returning empty table.');
                event_error_code = StatusCode.Error;
                new_events = ConsoleEvent(event_message, event_error_code, e);
                function_events = [function_events, new_events];
            end
        end

    end
end

