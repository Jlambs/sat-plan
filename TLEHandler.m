classdef TLEHandler < handle
    % TLEHANDLER Handler for Two-Line-Element (TLE) sets, which define properties
    % of a satellite.
    %   Detailed explanation goes here
    
    properties
        TLEHandles TLE
        TLEFactory TLEFactory = TLEFactory()
    end

    properties(Constant)
        DefaultOutputFileExtension = '.tle'  % FIXME: these variables probably don't need to exist
        DefaultOutputEncodingFormat = 'UTF-8'
        AllowedOutputEncodingFormats = {'UTF-8', 'US-ASCII'}
    end
    
    methods

        function addTLE(obj, tle_object)

            % Append new TLE object to list of TLE handles
            obj.TLEHandles(end+1) = tle_object;

        end

        function addTLEFromFile(obj, file_name)%, name_or_catalog_num)
            % File name checking could be done here or in TLE factory
            [new_TLE, is_valid] = obj.TLEFactory.createTLEFromFile(file_name);
            if is_valid
                obj.addTLE(new_TLE);
            else
                % Maybe the TLE factory will print this message, or give
                % more informative errors
                fprintf('Could not create valid TLE from %s. Skipping adding...\n', file_name)
            end
        end

        function addTLEFromURL(obj, url_string)%, name_or_catalog_num)
            % URL checking could be done here or in TLE factory
            [new_TLE, is_valid] = obj.TLEFactory.createTLEFromURL(url_string);
            if is_valid
                obj.addTLE(new_TLE);
            else
                % Maybe the TLE factory will print this message, or give
                % more informative errors
                fprintf('Could not create valid TLE from %s. Skipping adding...\n', url_string)
            end
        end

        function tle_handles = getTLEByName(obj, tle_name_str, return_all_instances)
            % Note: this function can't be used if the TLE doesn't have a
            % name defined, there may be a better way to do this

            % Loop through currently stored TLEs
            total_num_tles = length(obj.TLEHandles);
            tles_to_get = false(1, total_num_tles);
            for i = 1:total_num_tles

                current_TLE_name = obj.TLEHandles(i).SatelliteName;

                % Check to see if name matches
                if strcmpi(tle_name_str, current_TLE_name)  % not case sensitive
                    
                    % Flag TLE for returning
                    tles_to_get(i) = true;

                    % Check to see if return all instances flag wants us to
                    % stop here or not
                    if ~return_all_instances
                        break;
                    end

                end
                
            end

            % Return flagged TLEs
            tle_handles = obj.TLEHandles(tles_to_get);

        end

        function removeTLE(obj, tle_handle)

            obj.TLEHandles(isequal(TLEs, tle_handle)) = [];

            %fprintf('some sort of output statement here')
        end

        function removeTLEByName(obj, tle_name_str, delete_all_instances)
            % Note: this function can't be used if the TLE doesn't have a
            % name defined, there may be a better way to do this
            
            % Loop through currently stored TLEs
            total_num_tles = length(obj.TLEHandles);
            tles_to_delete = false(1, total_num_tles);
            for i = 1:total_num_tles

                current_TLE_name = obj.TLEHandles(i).SatelliteName;

                % Check to see if name matches
                if strcmpi(tle_name_str, current_TLE_name)  % not case sensitive
                    
                    % Flag TLE for deletion
                    tles_to_delete(i) = true;

                    % Check to see if delete all instances flag wants us to
                    % stop here or not
                    if ~delete_all_instances
                        break;
                    end

                end
                
            end

            % Delete flagged TLEs
            % FIXME: Not sure what the "best practice" way to do this is...
%             obj.TLE_handles(tles_to_delete) = [];
            tle_handles_to_delete = obj.TLEHandles(tles_to_delete);
            num_tles_to_delete = length(tle_handles_to_delete);
            for i = 1:num_tles_to_delete
                obj.removeTLE(tle_handles_to_delete(i));
            end

        end

        % FIXME: needs better name, and possibly to be merged with a
        % different function of a similar nature (see
        % validateAllTLEFormats)
        function tle_is_valid = validateTLEFormatByName(obj, tle_name_str)
            tle_handle = obj.getTLEByName(tle_name_str);
            tle_is_valid = tle_handle.FormatValid;
        end

        function [all_tles_valid, invalid_tles] = validateAllTLEFormats(obj)
            
            % Automatically return invalid if no TLEs are loaded
            total_num_tles = length(obj.TLEHandles);
            if total_num_tles == 0
                all_tles_valid = false;
                invalid_tles = [];
                return
            end
            
            % Loop through currently stored TLEs
            total_num_tles = length(obj.TLEHandles);
            tles_valid = false(1, total_num_tles);  % assume it's not valid until we confirm otherwise
            for i = 1:total_num_tles

                % Check validity
                current_TLE_is_valid = obj.TLEHandles(i).FormatValid;

                % Flag as valid
                if current_TLE_is_valid
                    tles_valid(i) = true;
                end

            end

            % Check if all TLEs are valid
            all_tles_valid = all(tles_valid);

            % Return flagged TLEs
            invalid_tles = obj.TLEHandles(tles_valid);

        end

        function [all_tles_valid, invalid_tles] = validateAllTLEChecksums(obj)
            
            % Automatically return invalid if no TLEs are loaded
            total_num_tles = length(obj.TLEHandles);
            if total_num_tles == 0
                all_tles_valid = false;
                invalid_tles = [];
                return
            end

            % Loop through currently stored TLEs
            tles_valid = false(1, total_num_tles);
            for i = 1:total_num_tles

                % Check validity
                current_TLE_is_valid = obj.TLEHandles(i).ChecksumValid;

                % Flag as valid
                if current_TLE_is_valid
                    tles_valid(i) = true;
                end

            end

            % Check if all TLEs are valid
            all_tles_valid = all(tles_valid);

            % Return flagged TLEs
            invalid_tles = obj.TLEHandles(tles_valid);
            
        end
        
        function saveTLEToFile(obj, tle_name_to_save, default_file_name, include_name_header, encoding_format, show_save_dialogue)
            % SAVETLETOFILE Helper function to save the TLE data to a file
            %   Detailed explanation goes here

            % FIXME: The UI portion of this function to select save
            % location should probably be moved into the app code itself?

            % TODO: support for writing out multiple TLEs to save file
            % TODO: general overhaul of TLE names, maybe require unique
            % name?
            tle_to_save = obj.getTLEByName(tle_name_to_save, false);
            
            % Prepare a default file name if none given
            if isempty(default_file_name)
                if ~isempty(tle_to_save.SatelliteName)
                    % Convert spaces to underscores
                    fixed_satellite_name = tle_to_save.SatelliteName;
                    fixed_satellite_name(fixed_satellite_name == ' ') = '_';
                    current_timestamp = datestr(datetime('now'), 30);  % Option 30 is yyyyMMddTHHmmSS
                    default_file_name = strcat(fixed_satellite_name, '_TLE_', current_timestamp);
                else
                    current_timestamp = datestr(datetime('now'), 30);  % Option 30 is yyyyMMddTHHmmSS
                    default_file_name = strcat('TLE_', current_timestamp);
                end
            end

%             % Add default file extension to file name if not included
%             if ~(endsWith(lower(default_file_name), '.tle') || ...
%                     endsWith(lower(default_file_name), '.txt'))
%                 default_file_name = strcat(default_file_name, obj.DefaultOutputFileExtension);
%             end
            
            if show_save_dialogue
                % Prompt user for file
                window_title = 'Save TLE as';
                [file, path] = uiputfile( ...
                    {'*.tle', 'TLE Files'; ...
                    '*.txt', 'Text Files'; ...
                    '*.*', 'All Files'}, ...
                    window_title, default_file_name);
                
                if isequal(file,0)
                    % TODO: Implement Sebastian's fix for this
                    disp('User selected Cancel, did not save.');
                   
                else
                    
                    % Successfully selected a file
                    TLE_dest = fullfile(path,file);
                    fprintf('User selected %s to save file at.\n', TLE_dest);
                end
            else
                TLE_dest = default_file_name;
            end
                
            % Open file, setting encoding type
            if isempty(encoding_format)
                encoding_format = obj.DefaultOutputEncodingFormat;
            end
            if any(ismember(obj.AllowedOutputEncodingFormats, encoding_format))
                TLE_file_ID = fopen(TLE_dest, 'w', 'native', encoding_format);
            else
                % TODO: error handling, and/or remove encoding
                % format stuff entirely
                fprintf('Must encode TLE in either UTF-8 or ASCII! Skipping writing to file.\n')
                return
            end
            
            % Check to see if we need to write satellite name
            if ~isempty(tle_to_save.SatelliteName) && include_name_header
                
                % Pad or truncate name to 24 characters
                raw_name = tle_to_save.SatelliteName;
                num_name_chars = length(raw_name);
                standard_TLE_satellite_name_length = 24;  % this value will never change, so it feels okay to hardcode it
                if num_name_chars > standard_TLE_satellite_name_length
                    fixed_length_name = raw_name(1:standard_TLE_satellite_name_length);
                else
                    fixed_length_name = pad(raw_name, standard_TLE_satellite_name_length, 'right', ' ');
                end
                
                % Write fixed length name to file
                fprintf(TLE_file_ID, '%s\n', fixed_length_name);
                
            end
            
            % Write TLE lines to file
            TLE_line_1 = tle_to_save.TLELine1;
            TLE_line_2 = tle_to_save.TLELine2;
            fprintf(TLE_file_ID, '%s\n', TLE_line_1);
            fprintf(TLE_file_ID, '%s', TLE_line_2);
            
            % Close file
            fclose(TLE_file_ID);
        
        end

        function satellite_table = generateLoadedSatelliteTable()
            % TODO
            satellite_table = table();
        end

        function addSunSynchronousOrbit(obj)

            obj.TLEFactory.addSunSynchOrbit();

        end

        function addGeoStationaryOrbit(obj)

            keplerian_elems  = [1,2,3];
            
            new_TLE_obj = TLE();
            new_TLE_obj.Inclination = keplerian_elems(1);

        end

    end

end

