function true_anomaly_deg = meanAnomalyToTrueAnomalyd(mean_anomaly_deg, eccentricity)
%MEANANOMALYTOTRUEANOMALYD Converts mean anomaly to true anomaly, in
%degrees.
    % TODO: add input checks:
    %   1) 0 <= eccentricity < 1 (or 0 <= eccentricity < 0.6627?)
    %   2) 0 deg <= mean_anomaly_deg < 360 deg (?)

    mean_anomaly_rad = deg2rad(mean_anomaly_deg);

    % Use formula found here https://en.wikipedia.org/wiki/Equation_of_the_center
    % Note: accurate for small values of e, e > 0.6627... may
    % have unpredictable results
    % Uses full 7th-order truncation, because why not        
    true_anomaly_rad = mean_anomaly_rad + ...
        (2*eccentricity - 1/4*eccentricity^3 + 5/96*eccentricity^5 + 107/4608*eccentricity^7) * sin(mean_anomaly_rad) + ...
        (5/4*eccentricity^2 - 11/24*eccentricity^4 + 17/192*eccentricity^6) * sin(2*mean_anomaly_rad) + ...
        (13/12*eccentricity^3 - 43/64*eccentricity^5 + 95/512*eccentricity^7) * sin(3*mean_anomaly_rad) + ...
        (103/96*eccentricity^4 - 451/480*eccentricity^6) * sin(4*mean_anomaly_rad) + ...
        (1097/960*eccentricity^5 - 5957/4608*eccentricity^7) * sin(5*mean_anomaly_rad) + ...
        1223/960*eccentricity^6 * sin(6*mean_anomaly_rad) + 47273/32256*eccentricity^7 * sin(7*mean_anomaly_rad);

    true_anomaly_deg = rad2deg(true_anomaly_rad);

end