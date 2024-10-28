% Set up DAQ session
daqSession = daq('ni'); % Adjust 'ni' if using a different vendor

% Set sample rate (adjust based on desired resolution and DAQ specs)
daqSession.Rate = 1000; % 1000 samples per second, adjust as needed

% Add channels for Sync In (Digital Output) and Sync Out (Analog Input)
% Adjust the channels based on your specific DAQ board configuration
ch(1) = addAnalogInputChannel(daqSession, 'Dev1', 'ai1', 'Voltage'); % Sync Out Train
addAnalogInputChannel(daqSession, 'Dev1', 'ai2', 'Voltage'); % Sync Out Stim
addAnalogInputChannel(daqSession, 'Dev1', 'ai3', 'Voltage'); % Sync Out Delay
addDigitalChannel(daqSession, 'Dev1', 'port0/line0', 'OutputOnly'); % Sync In Stim
addDigitalChannel(daqSession, 'Dev1', 'port0/line1', 'OutputOnly'); % Sync In Delay
addDigitalChannel(daqSession, 'Dev1', 'port0/line2', 'OutputOnly'); % Sync In Train Duration

% Initialize live plot figure
figure;
hold on;
title('Live Data from DAQ Channels');
xlabel('Time (s)');
ylabel('Voltage / Digital Signal');
grid on;

% Create line objects for each channel to update during the loop
syncOutTrainLine = plot(nan, nan, 'DisplayName', 'Sync Out Train');
syncOutStimLine = plot(nan, nan, 'DisplayName', 'Sync Out Stim');
syncOutDelayLine = plot(nan, nan, 'DisplayName', 'Sync Out Delay');
legend show;

% Initialize time and data arrays
timeVec = [];
syncOutTrainData = [];
syncOutStimData = [];
syncOutDelayData = [];

% Start live data acquisition
startBackground(daqSession); % Start the session in background

% Define the duration of live plotting (in seconds)
duration = 10; % adjust as needed

tic; % Start timer
while toc < duration
    % Read data for each analog input channel
    [data, timestamps] = daqSession.inputSingleScan();
   
    % Update time and data arrays for each channel
    timeVec = [timeVec, toc]; % Current time
    syncOutTrainData = [syncOutTrainData, data(1)];
    syncOutStimData = [syncOutStimData, data(2)];
    syncOutDelayData = [syncOutDelayData, data(3)];
   
    % Update plot data
    set(syncOutTrainLine, 'XData', timeVec, 'YData', syncOutTrainData);
    set(syncOutStimLine, 'XData', timeVec, 'YData', syncOutStimData);
    set(syncOutDelayLine, 'XData', timeVec, 'YData', syncOutDelayData);
   
    drawnow; % Update figure
end

% Stop session
stop(daqSession);
release(daqSession); % Release DAQ resources
disp('Live plotting complete.');