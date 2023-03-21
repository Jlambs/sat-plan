classdef TabState
    % TABSTATE All properties of a tab state, including description, color,
    % and id. This class has no methods, so perhaps should be changed to a
    % struct in the future.
    %   Detailed explanation goes here
    
    properties
        Color (1,3) double {mustBeGreaterThanOrEqual(Color, 0), mustBeLessThanOrEqual(Color, 1)}
    end
    
    methods
        function state = TabState(color)
            % TABSTATE Construct an instance of this class
            %   Detailed explanation goes here
            state.Color = color;
        end
    end

    enumeration
        NotReady ([1, 0, 0])  % red
        Waiting  ([1, 1, 0])  % yellow
        Complete ([0, 1, 0])  % green
        Error    ([0, 0, 0])
    end
end

