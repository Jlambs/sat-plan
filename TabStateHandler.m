classdef TabStateHandler < handle
    % TABSTATEHANDLER Keeps track of each tab's state, and updates tabs
    % if an event is recieved.
    %   TODO: Detailed explanation
    
    properties%(Constant, Access=private)
        StateMachine
    end

    properties
        SatelliteTabState = TabState.NotReady;
        PropagationTabState = TabState.NotReady;
        AccessTabState = TabState.NotReady;
        TargetTabState = TabState.NotReady;
        ExposureTabState = TabState.NotReady;
        ConflictsTabState = TabState.NotReady;
        ExportJSONTabState = TabState.NotReady;
    end
    
    methods
        function obj = TabStateHandler
            % TABSTATEHANDLER Construct an instance of this class
            obj.StateMachine = GUIStateMachine();

        end

        function sendTransitionEvent(obj, event_name_str)

            switch event_name_str
                
                case 'GUI_INITIALIZATION_COMPLETE'
                    GUI_INITIALIZATION_COMPLETE(obj.StateMachine);

                case 'SATELLITE_DEFINITION_VALID'
                    SATELLITE_DEFINITION_VALID(obj.StateMachine);

                case 'SATELLITE_DEFINITION_CHANGED'
                    SATELLITE_DEFINITION_CHANGED(obj.StateMachine);

                case 'GROUND_STATION_ACCESS_CHANGED'
                    GROUND_STATION_ACCESS_CHANGED(obj.StateMachine);

                case 'GROUND_STATION_ACCESS_CALCULATED'
                    GROUND_STATION_ACCESS_CALCULATED(obj.StateMachine);

                case 'PROPAGATION_CALCULATED'
                    PROPAGATION_CALCULATED(obj.StateMachine);

                case 'PROPAGATION_CHANGED'
                    PROPAGATION_CHANGED(obj.StateMachine);

                case 'TARGET_VISIBILITY_CALCULATED'
                    TARGET_VISIBILITY_CALCULATED(obj.StateMachine);

                case 'TARGET_VISIBILITY_CHANGED'
                    TARGET_VISIBILITY_CHANGED(obj.StateMachine);

                case 'PLAN_HAS_CONFLICTS'
                    PLAN_HAS_CONFLICTS(obj.StateMachine);

                case 'PLAN_HAS_NO_CONFLICTS'
                    PLAN_HAS_NO_CONFLICTS(obj.StateMachine);

                case 'EXPOSURES_ADDED'
                    EXPOSURES_ADDED(obj.StateMachine);

                case 'NO_EXPOSURES_ADDED'
                    NO_EXPOSURES_ADDED(obj.StateMachine);

                case 'READY_FOR_EXPORT'
                    READY_FOR_EXPORT(obj.StateMachine);

                case 'NOT_READY_FOR_EXPORT'
                    NOT_READY_FOR_EXPORT(obj.StateMachine);

                otherwise
                    % TODO: proper error handling
                    fprintf('%s is not a valid event name.\n', event_name_str)
            end

            obj.updateTabStates();

        end

        function updateTabStates(obj)

            active_states = obj.StateMachine.getActiveStates();

            for i = 1:numel(active_states)
                
                current_state_name = active_states{i};

                % Set TLE tab state
                if startsWith(current_state_name, 'SatelliteDefinition.')
                    if endsWith(current_state_name, 'NotReady')
                        new_state = TabState.NotReady;
                    elseif endsWith(current_state_name, 'Waiting')
                        new_state = TabState.Waiting;
                    elseif endsWith(current_state_name, 'Complete')
                        new_state = TabState.Complete;
                    else
                        % TODO: error handling etc
                        new_state = TabState.Error;
                    end
                    obj.SatelliteTabState = new_state;
                end

                % Set SGP4 tab state
                if startsWith(current_state_name, 'Propagation.')
                    if endsWith(current_state_name, 'NotReady')
                        new_state = TabState.NotReady;
                    elseif endsWith(current_state_name, 'Waiting')
                        new_state = TabState.Waiting;
                    elseif endsWith(current_state_name, 'Complete')
                        new_state = TabState.Complete;
                    else
                        % TODO: error handling etc
                        new_state = TabState.Error;
                    end
                    obj.PropagationTabState = new_state;
                end
                
                % Set Ground Stations tab state
                if startsWith(current_state_name, 'GroundStationAccess.')
                    if endsWith(current_state_name, 'NotReady')
                        new_state = TabState.NotReady;
                    elseif endsWith(current_state_name, 'Waiting')
                        new_state = TabState.Waiting;
                    elseif endsWith(current_state_name, 'Complete')
                        new_state = TabState.Complete;
                    else
                        % TODO: error handling etc
                        new_state = TabState.Error;
                    end
                    obj.AccessTabState = new_state;
                end
    
                % Set Targets tab state
                if startsWith(current_state_name, 'TargetVisibility.')
                    if endsWith(current_state_name, 'NotReady')
                        new_state = TabState.NotReady;
                    elseif endsWith(current_state_name, 'Waiting')
                        new_state = TabState.Waiting;
                    elseif endsWith(current_state_name, 'Complete')
                        new_state = TabState.Complete;
                    else
                        % TODO: error handling etc
                        new_state = TabState.Error;
                    end
                    obj.TargetTabState = new_state;
                end
    
                % Set Exposures tab state
                if startsWith(current_state_name, 'Exposures.')
                    if endsWith(current_state_name, 'NotReady')
                        new_state = TabState.NotReady;
                    elseif endsWith(current_state_name, 'Waiting')
                        new_state = TabState.Waiting;
                    elseif endsWith(current_state_name, 'Complete')
                        new_state = TabState.Complete;
                    else
                        % TODO: error handling etc
                        new_state = TabState.Error;
                    end
                    obj.ExposureTabState = new_state;
                end
    
                % Set Conflicts tab state
                if startsWith(current_state_name, 'ConflictResolution.')
                    if endsWith(current_state_name, 'NotReady')
                        new_state = TabState.NotReady;
                    elseif endsWith(current_state_name, 'Waiting')
                        new_state = TabState.Waiting;
                    elseif endsWith(current_state_name, 'Complete')
                        new_state = TabState.Complete;
                    else
                        % TODO: error handling etc
                        new_state = TabState.Error;
                    end
                    obj.ConflictsTabState = new_state;
                end
    
                % Set Export JSON tab state
                if startsWith(current_state_name, 'ExportJSON.')
                    if endsWith(current_state_name, 'NotReady')
                        new_state = TabState.NotReady;
                    elseif endsWith(current_state_name, 'Waiting')
                        new_state = TabState.Waiting;
                    elseif endsWith(current_state_name, 'Complete')
                        new_state = TabState.Complete;
                    else
                        % TODO: error handling etc
                        new_state = TabState.Error;
                    end
                    obj.ExportJSONTabState = new_state;
                end

            end

        end

        function [tle_tab_state, sgp4_tab_state, ground_stations_tab_state, ...
                targets_tab_state, exposures_tab_state, conflicts_tab_state, ...
                export_json_tab_state] = getAllStates(obj)

            % FIXME: better organization of output params
            tle_tab_state = obj.SatelliteTabState;
            sgp4_tab_state = obj.PropagationTabState;
            ground_stations_tab_state = obj.AccessTabState;
            targets_tab_state = obj.TargetTabState;
            exposures_tab_state = obj.ExposureTabState;
            conflicts_tab_state = obj.ConflictsTabState;
            export_json_tab_state = obj.ExportJSONTabState;

        end

%         % TODO: flesh this out a bit more? Function to start, stop, reset
%         % stateflow object could be handy, but probably not necessary
%         function deleteStateMachine(obj)
% 
%             %obj.StateMachine.delete();
%              delete(obj.StateMachine);
%              clear obj.StateMachine;
% 
%         end

        % Implement destructor which explicitly deletes state machine
        % object
        function delete(obj)
            delete(obj.StateMachine);
        end

    end
end

