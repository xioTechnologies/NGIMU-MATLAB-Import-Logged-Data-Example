clc
clear
close all;

%% Import data

sessionData = importSession('My Session');

%% Resample data

[resampledSessionData, time] = resampleSession(sessionData, 0.01);

%% Plot synchronised gyroscope data

deviceColours = hsv(resampledSessionData.numberOfDevices);

figure;
for deviceIndex = 1:resampledSessionData.numberOfDevices
    deviceName = resampledSessionData.deviceNames{deviceIndex};
    deviceColour = deviceColours(deviceIndex, :);

    subplot(3,1,1);
    hold on;
    plot(time, resampledSessionData.(deviceName).sensors.gyroscopeX, 'Color', deviceColour);
    title('Gyroscope X axis');
    xlabel('Time (s)');
    ylabel('deg/s');

    subplot(3,1,2);
    hold on;
    plot(time, resampledSessionData.(deviceName).sensors.gyroscopeY, 'Color', deviceColour);
    title('Gyroscope Y axis');
    xlabel('Time (s)');
    ylabel('deg/s');

    subplot(3,1,3);
    hold on;
    plot(time, resampledSessionData.(deviceName).sensors.gyroscopeZ, 'Color', deviceColour);
    title('Gyroscope Z axis');
    xlabel('Time (s)');
    ylabel('deg/s');
end
