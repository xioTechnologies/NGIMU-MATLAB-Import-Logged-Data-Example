function [resampledSessionData, time] = resampleSession(sessionData, newSamplePeriod)

    % Copy original structure
    resampledSessionData = sessionData;

    % Determine end time
    endTime = -Inf;
    for deviceIndex = 1:sessionData.numberOfDevices
        deviceName = sessionData.deviceNames{deviceIndex};
        csvFileNames = fieldnames(sessionData.(deviceName));
        for csvFileIndex = 1:length(csvFileNames)
            maxTime = max(sessionData.(deviceName).(csvFileNames{csvFileIndex}).time);
            if maxTime > endTime
                endTime = maxTime;
            end
        end
    end
    endTime = floor(endTime / newSamplePeriod) * newSamplePeriod;

    % Create resampled time vector
    time = [0:newSamplePeriod:endTime]';

    % Loop through each device
    for deviceIndex = 1:sessionData.numberOfDevices
        deviceName = sessionData.deviceNames{deviceIndex};

        % Loop through each CSV file
        csvFileNames = fieldnames(sessionData.(deviceName));
        for csvFileIndex = 1:length(csvFileNames)
            csvFileName = csvFileNames{csvFileIndex};

            % Overwrite time
            resampledSessionData.(deviceName).(csvFileName).time = time;

            % Interpolate quaternion CSV file
            if strcmp(csvFileName, 'quaternion')
                resampledSessionData.(deviceName).(csvFileName).vector = interpolateQuaternion(sessionData.(deviceName).(csvFileName).time, ...
                                                                                               sessionData.(deviceName).(csvFileName).vector, ...
                                                                                               time);
                resampledSessionData.(deviceName).quaternion.w = resampledSessionData.(deviceName).quaternion.vector(:,1);
                resampledSessionData.(deviceName).quaternion.x = resampledSessionData.(deviceName).quaternion.vector(:,2);
                resampledSessionData.(deviceName).quaternion.y = resampledSessionData.(deviceName).quaternion.vector(:,3);
                resampledSessionData.(deviceName).quaternion.z = resampledSessionData.(deviceName).quaternion.vector(:,4);
                continue;
            end

            % Skip rotation matrix CSV file
            if strcmp(csvFileName, 'matrix')
                sessionData.(deviceName) = rmfield(sessionData.(deviceName), csvFileName); % remove field
                warning('Rotation matrix cannot be resampled.  This field has been removed from the data structure.');
                continue;
            end

            % Loop through each CSV column
            csvColumnNames = fieldnames(sessionData.(deviceName).(csvFileName));
            for csvColumnIndex = 1:length(csvColumnNames)
                csvColumnName = csvColumnNames{csvColumnIndex};

                % Skip time column
                if strcmp(csvColumnName, 'time')
                    continue;
                end

                % Interpolate data column
                resampledSessionData.(deviceName).(csvFileName).(csvColumnName) = interp1(sessionData.(deviceName).(csvFileName).time, ...
                                                                                          sessionData.(deviceName).(csvFileName).(csvColumnName), ...
                                                                                          time, ...
                                                                                          'linear', 'extrap');
            end
        end
    end
end

function interpolatedQuaternion = interpolateQuaternion(orginalTime, orginalQuaternion, newTime)

    % Linear interpolation, TODO: use slerp, https://en.wikipedia.org/wiki/Slerp
    interpolatedQuaternion = interp1(orginalTime, orginalQuaternion, newTime, 'linear', 'extrap');

    % Normalise quaternion
    numberOfRows = size(interpolatedQuaternion, 1);
    for rowIndex = 1:numberOfRows
        interpolatedQuaternion(rowIndex,:) = interpolatedQuaternion(rowIndex,:) * (1 / norm(interpolatedQuaternion(rowIndex,:)));
    end
end
