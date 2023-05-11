function [year_num, day_of_year] = datetimeToYearAndDOY(input_datetime)
% DATETIMETOYEARANDDOY Coverts a datetime to a year and day of year (as a
% decimal).

    % Get year
    year_num = year(input_datetime);

    % Convert from datetime to day of year as decimal
    day_of_year = days(days(day(input_datetime, 'dayofyear')) + ...
        hours(hour(input_datetime)) + minutes(minute(input_datetime)) + ...
        seconds(second(input_datetime)));

end