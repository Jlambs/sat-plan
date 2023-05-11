function semimajor_axis_m = meanMotionToSemimajorAxis(mean_motion_rev_per_day)
% MEANMOTIONTOSEMIMAJORAXIS Convert mean motion to semi-major axis. Mean
% motion is given in [rev/day], semimajor_axis is returned in [m].

    % Define constants
    rev_per_day_to_rad_per_sec = (2*pi) / (24*60*60);  % conversion from [rev/day] to [rad/s]
    geocentric_gravitational_const = 3.986004418e14;  % [m^3/s^2], mu=G*M_Earth, see https://iau-a3.gitlab.io/NSFA/NSFA_cbe.html#GME2009
    
    % Convert mean motion to [rad/s]
    mean_motion_rad_per_sec = mean_motion_rev_per_day * rev_per_day_to_rad_per_sec;
    
    % Use formula found here https://en.wikipedia.org/wiki/Mean_motion
    semimajor_axis_m = (geocentric_gravitational_const/mean_motion_rad_per_sec^2)^(1/3);

end