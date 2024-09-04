%%%Recording mic data using a manual trigger (newer daq code)
%Adi 10/27/22 edited by Michael Wilkinson
%Adi 11/16/22

%% Start Loop
a = datetime('now', 'Format', 'yyyyMMdd');
date = strcat(num2str(a.Year), '0', num2str(a.Month), num2str(a.Day));
bat = 'BAT_ID';
ParentFolder = 'C:\Users\jsayles3\Desktop\Mic Test 3';
mkdir(ParentFolder, date)
pathh = strcat('C:\Users\jsayles3\Desktop\Mic Test 3\', date);
cd(pathh)

i = 1;
while i > -1 % No limit to the number of trials

    if i < 10
        file_name = strcat(bat, '_', date, '_trial0', num2str(i), '.mat');
    else
        file_name = strcat(bat, '_', date, '_trial', num2str(i), '.mat');  
    end 

    %% Creating a new session
    ai = daq('ni');

    %% Creating Input Channels
    ch(1) = addinput(ai, 'Dev1', 'ai0', 'Voltage'); % microphone for vocalization
    ch(2) = addinput(ai, 'Dev1', 'ai1', 'Voltage'); % microphone for echo
    ch(3) = addinput(ai, 'Dev1', 'ai2', 'Voltage'); % third channel for new signal
    ch(1).TerminalConfig = 'Differential';
    ch(2).TerminalConfig = 'Differential';
    ch(3).TerminalConfig = 'Differential'; % Third channel also in differential mode

    % Adding an external trigger
    addtrigger(ai, "Digital", "StartTrigger", "External", "Dev1/PFI0");
    ai.DigitalTriggers(1).Condition = "RisingEdge";
    ai.NumDigitalTriggersPerRun = 1;
    ai.DigitalTriggerTimeout = 300000;

    %% Specifying Duration and Sampling Rate
    ai.Rate = 250000;
    fprintf('Trigger for Trial %d\n', i)

    % Get Data
    [data, timestamps] = read(ai, seconds(2)); % RECORD LENGTH
    channel1_vect = data(1:end, 1); % Previously mic
    channel2_vect = data(1:end, 2); % Previously echo
    channel3_vect = data(1:end, 3); % Third channel

    % Save Data
    channel_data.channel1_sig = channel1_vect;
    channel_data.channel2_sig = channel2_vect;
    channel_data.channel3_sig = channel3_vect; % Save third channel data
    channel_data.sample_rate = ai.Rate;
    channel_data.trial_num = i;

    figure()

    % Plot the channel1 signal (vocalization signal)
    subplot(3, 2, 1)
    plot(channel_data.channel1_sig)
    title('Channel 1 Signal (Time Domain)')
    xlabel('Sample Number')
    ylabel('Amplitude')

    subplot(3, 2, 3)
    spectrogram(channel_data.channel1_sig, 512, 256, 512, 250000, 'yaxis')
    title('Channel 1 Signal (Spectrogram)')

    % Plot the channel2 signal (echo signal)
    subplot(3, 2, 2)
    plot(channel_data.channel2_sig)
    title('Channel 2 Signal (Time Domain)')
    xlabel('Sample Number')
    ylabel('Amplitude')

    subplot(3, 2, 4)
    spectrogram(channel_data.channel2_sig, 512, 256, 512, 250000, 'yaxis')
    title('Channel 2 Signal (Spectrogram)')

    % Plot the channel3 signal (new signal)
    subplot(3, 2, 5)
    plot(channel_data.channel3_sig)
    title('Channel 3 Signal (Time Domain)')
    xlabel('Sample Number')
    ylabel('Amplitude')

    subplot(3, 2, 6)
    spectrogram(channel_data.channel3_sig, 512, 256, 512, 250000, 'yaxis')
    title('Channel 3 Signal (Spectrogram)')

    % Save data to a file
    save(file_name, "channel_data");

    % Clear variables for next trial
    clearvars channel1_vect channel2_vect channel3_vect channel_data
    daqreset

    i = i + 1;
end
