function mean_motion_rev_per_day = semimajorAxisToMeanMotion(semimajor_axis_m)
% SEMIMAJORAXISTOMEANMOTION Convert semi-major axis to mean motion. Mean
% motion is returned in [rev/day], semimajor_axis is given in [m].

    % Define constants
    rad_per_sec_to_rev_per_day = (24*60*60) / (2*pi);  % conversion from [rad/s] to [rev/day]
    geocentric_gravitational_const = 3.986004418e14;  % "mu", see https://iau-a3.gitlab.io/NSFA/NSFA_cbe.html#GME2009
    
    % Use formula found here https://en.wikipedia.org/wiki/Mean_motion
    mean_motion_rad_per_sec = (geocentric_gravitational_const/semimajor_axis_m^3)^(1/2);
    
    % Convert mean motion to [rev/day]
    mean_motion_rev_per_day = mean_motion_rad_per_sec * rad_per_sec_to_rev_per_day;

end