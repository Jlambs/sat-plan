classdef SatelliteScenarioHandler < handle
    % SATELLITEPROPERTIES Houses and controls the satelliteScenario object,
    % as well as satellites added to it.
    %    Detailed explanation goes here
    
    properties
        % TODO: better access types for these
        SatelliteScenario satelliteScenario = satelliteScenario()
        ScenarioStartDatetime datetime  
        ScenarioEndDatetime datetime
        ScenarioTimestepSizeSec double

        Satellites cell  % no validation for Satellite type, unfortunately
    end
    
    methods
%         function obj = SatelliteScenarioHandler(sat_scenario)
%             % SATELLITESCENARIOHANDLER Construct an instance of this class
%             %   Detailed explanation goes here
%             obj.SatelliteScenario = sat_scenario;
%         end
        
        function addSatelliteFromTLEFile(obj, tle_file_name)
            obj.Satellites{end+1} = satellite(obj.SatelliteScenario, tle_file_name);
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

    end
end

