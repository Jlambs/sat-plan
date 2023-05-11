function new_datetime = yearAndDOYToDatetime(input_year, day_of_year)
% YEARANDDOYTODATETIME Coverts a And day of year (as a decimal) to a
% datetime.

    input_year_str = num2str(input_year, '%04d');
    new_datetime = datetime(input_year_str, 'InputFormat', 'yyyy') + ...
            days(day_of_year);

end