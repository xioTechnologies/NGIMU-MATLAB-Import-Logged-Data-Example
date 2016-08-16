clc
clear
close all;

%% Import data

sessionData = importSession('My Session');

%% Resample data

[time, sessionData] = resampleSession(sessionData, 0.01);

%% Plot synchronised gyroscope data

deviceColours = hsv(sessionData.numberOfDevices);

figure;
for deviceIndex = 1:sessionData.numberOfDevices
    deviceName = sessionData.deviceNames{deviceIndex};
    deviceColour = deviceColours(deviceIndex, :);

    subplot(3,1,1);
    hold on;
    plot(time, sessionData.(deviceName).sensors.gyroscopeX, 'Color', deviceColour);
    title('Gyroscope X axis');
    xlabel('Time (s)');
    ylabel('deg/s');

    subplot(3,1,2);
    hold on;
    plot(time, sessionData.(deviceName).sensors.gyroscopeY, 'Color', deviceColour);
    title('Gyroscope Y axis');
    xlabel('Time (s)');
    ylabel('deg/s');

    subplot(3,1,3);
    hold on;
    plot(time, sessionData.(deviceName).sensors.gyroscopeZ, 'Color', deviceColour);
    title('Gyroscope Z axis');
    xlabel('Time (s)');
    ylabel('deg/s');
end
