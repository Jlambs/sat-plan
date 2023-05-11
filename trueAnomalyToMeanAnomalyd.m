function mean_anomaly_deg = trueAnomalyToMeanAnomalyd(true_anomaly_deg, eccentricity)
%TRUEANOMALYTOMEANANOMALYD Converts mean anomaly to true anomaly, in
%degrees.
    % TODO: add input checks:
    %   1) 0 <= eccentricity < 1 (or 0 <= eccentricity < 0.6627?)
    %   2) 0 deg <= true_anomaly_deg < 360 deg (?)

    true_anomaly_rad = deg2rad(true_anomaly_deg);

    % Use formula found here https://en.wikipedia.org/wiki/Equation_of_the_center
    % Note: accurate for small values of e, e > 0.6627... may
    % have unpredictable results
    % Use geometric formula (derived from Kepler's equation)
    % FIXME: is series expansion formula more accurate, or just an approximation of this?
    mean_anomaly_rad = atan2(-sqrt(1-eccentricity^2)*sin(true_anomaly_rad), -eccentricity-cos(true_anomaly_rad)) + ...
        pi - eccentricity * (sqrt(1-eccentricity^2)*sin(true_anomaly_rad) / (1 + eccentricity*cos(true_anomaly_rad)));

    mean_anomaly_deg = rad2deg(mean_anomaly_rad);

end