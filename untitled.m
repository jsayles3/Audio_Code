% Initialize DAQ session
daqSession = daq('ni');

% Define analog input channels to record S48 outputs
addAnalogInputChannel(daqSession, 'Dev1', 'ai1', 'Voltage'); % Sync Out
addAnalogInputChannel(daqSession, 'Dev1', 'ai2', 'Voltage'); % Stimulation Out

% Define a digital output channel for sending the trigger to the S48
triggerOutput = addDigitalChannel(daqSession, 'Dev1', 'port0/line0', 'OutputOnly'); % Trigger output

% Set Analog Channels to Differential if needed
daqSession.Channels(1).TerminalConfig = 'Differential';
daqSession.Channels(2).TerminalConfig = 'Differential';

% Configure DAQ sample rate and recording duration
daqSession.Rate = 250000;
recordDuration = seconds(2);

% Initialize date and directory for saving data
a = datetime('now', 'Format', 'yyyyMMdd');
date = strcat(num2str(a.Year), '0', num2str(a.Month), num2str(a.Day));
bat = 'BAT_ID';
ParentFolder = 'C:\Users\jsayles3\Desktop\Mic Test 3';
mkdir(ParentFolder, date);
pathh = fullfile(ParentFolder, date);
cd(pathh);

% Start Loop for trials
i = 1;
while i > -1  % Run continuously until stopped
    % Define file name for each trial with zero-padded trial number
    if i < 10
        file_name = strcat(bat, '_', date, '_trial0', num2str(i), '.mat');
    else
        file_name = strcat(bat, '_', date, '_trial', num2str(i), '.mat');
    end

    fprintf('Waiting for trigger button press for Trial %d\n', i);

    % Check for button press and send trigger signal
    % Assuming you have a button condition (e.g., read from a separate input)
    % Here we simulate sending a trigger pulse
    outputSingleScan(daqSession, 1); % Set trigger output high
    pause(0.01);                     % Short pulse duration
    outputSingleScan(daqSession, 0); % Set trigger output low

    % Collect data from S48 outputs after trigger
    [data, timestamps] = read(daqSession, recordDuration);
    syncOutData = data(:, 1);  % Sync Output from S48
    stimOutData = data(:, 2);  % Stimulation Output from S48

    % Organize data into a structure for saving
    output_data.sync_out = syncOutData;
    output_data.stim_out = stimOutData;
    output_data.sample_rate = daqSession.Rate;
    output_data.trial_num = i;

    % Plotting
    figure;
    
    % Plot Sync Output
    subplot(2, 1, 1);
    plot(output_data.sync_out);
    title('Sync Output Signal (Time Domain)');
    xlabel('Sample Number');
    ylabel('Amplitude');

    % Plot Stimulation Output
    subplot(2, 1, 2);
    plot(output_data.stim_out);
    title('Stimulation Output Signal (Time Domain)');
    xlabel('Sample Number');
    ylabel('Amplitude');

    % Save data
    save(file_name, "output_data");

    % Clean up for next trial
    clearvars syncOutData stimOutData output_data;
    i = i + 1;
end

% Reset DAQ session after loop completion
daqreset;
