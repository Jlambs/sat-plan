classdef GUIEventLog < handle
    % GUIEVENTLOG Append-only log of all events encountered by the GUI.
    % This is mostly used for printing output to the console log.

    properties (Access = private)
        EventList(1,:) ConsoleEvent
    end
    % FIXME: not sure if these should be public or not, or have overridden
    % set/get methods
    properties (Access = public)
        Verbose logical = false
        TimestampFormat {mustBeText} = '[HH:mm:ss]'
    end

    methods (Access = public)
        
        function raw_text = generateConsoleLogText(obj)
            
            % try

                total_num_events = length(obj.EventList);
                raw_text = cell(1, total_num_events);
    
                for i = 1:total_num_events
                    current_event = obj.EventList(i);
                    timestamp_format = obj.TimestampFormat;
                    verbose_flag = obj.Verbose;
                    current_event_text = current_event.generateTextOutput(timestamp_format, verbose_flag);
                    raw_text{i} = current_event_text;
                end

                % Convert text to a complete string
                raw_text = cell2str(raw_text, '\n');

            % catch e
            %     event_message = 'Failed to generate console log event text.';
            %     event_ts = datetime('now');
            %     event_error_code = StatusCode.Error;
            %     function_events = GUIEvent(event_message, event_ts, event_error_code, e);
            % end

        end

        function addGUIEvent(obj, new_event)

            % try
                old_event_list = obj.EventList;
                new_event_list = [old_event_list, new_event];
                obj.EventList = new_event_list;
            % catch e
            %     event_message = 'Failed to add GUI event to event log.';
            %     event_ts = datetime('now');
            %     event_error_code = StatusCode.Error;
            %     function_events = GUIEvent(event_message, event_ts, event_error_code, e);
            % end

        end

        function deleteAllEvents(obj)
            obj.EventList(:) = [];
        end

    end


end