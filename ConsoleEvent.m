classdef ConsoleEvent

    properties
        Message %{mustBeText(Message)}
        EventStatusCode StatusCode = StatusCode.Success      
        Timestamp datetime
        Exception MException = MException.empty
    end

    methods
        
        function obj = ConsoleEvent(message, status_code, exception)
            obj.Message = message;
            obj.Timestamp = datetime('now');
            if nargin >= 2
                obj.EventStatusCode = status_code;
            end
            if nargin == 3
                obj.Exception = exception;
            end
        end

        function event_text = generateTextOutput(obj, timestamp_format, verbose)
            
            % try

                % Generate timestamp text
                timestamp_formatted = obj.Timestamp;
                timestamp_formatted.Format = timestamp_format;
                timestamp_text = [char(timestamp_formatted), ' '];
    
                % Prepend from status code
                status_code_text = obj.EventStatusCode.TextOutput;
                if ~isempty(status_code_text)
                    % Append space if necessary
                    status_code_text = [status_code_text, ' '];
                end
    
                % Determine body of message based on verbose flag
                message_text = obj.Message;
                if verbose
                    % So far the only thing verbosity does is print the
                    % exception information
                    if ~isempty(obj.Exception)
                        extra_error_text = getReport(obj.Exception, 'extended', 'hyperlinks', 'off');
                        message_text = [message_text, newline, newline, extra_error_text];
                    end
                end
    
                % Put it all together (spaces already included)
                event_text = [timestamp_text, status_code_text, message_text];

            % catch e
            % 
            %     event_message = 'Failed to generate event text.';
            %     event_ts = datetime('now');
            %     event_error_code = StatusCode.Error;
            %     function_events = GUIEvent(event_message, event_ts, event_error_code, e);
            % 
            % end


        end

    end



end