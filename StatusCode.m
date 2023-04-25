classdef StatusCode
    % STATUSCODE All properties of a GUI event status code.
    %   Detailed explanation goes here
    
    properties
        TextOutput %{mustBeTextScalar(TextOutput)}
        TableStyle %{mustBeA(TableStyle, matlab.ui.style.Style)} %(1,3) double {mustBeGreaterThanOrEqual(TableColor, 0), mustBeLessThanOrEqual(TableColor, 1)}
        % MessageStyle uistyle%(1,3) double {mustBeGreaterThanOrEqual(MessageColor, 0), mustBeLessThanOrEqual(MessageColor, 1)}
    end
    
    methods
        function status_code = StatusCode(text_output, table_color)%, message_color)
            % STATUSCODE Construct an instance of this class
            %   Detailed explanation goes here
            status_code.TextOutput = text_output;
            status_code.TableStyle = uistyle('BackgroundColor', table_color);
            % status_code.MessageColor = message_color;
        end
    end

    enumeration
        Success ('', [0, 1, 0])%, [0, 1, 0])  % green
        Warning ('Warning:', [1, 1, 0])%, [0, 1, 0])  % yellow
        Error   ('Error:', [1, 0, 0])%, [0, 1, 0])  % red
    end
end

