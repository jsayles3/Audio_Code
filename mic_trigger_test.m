% Fixed MATLAB script for recording triggered data
a = datetime('now', 'Format', 'yyyyMMdd');
date = datestr(a, 'yyyyMMdd');
bat = 'BAT_ID';
ParentFolder = 'C:\Users\jsayles3\Desktop\Mic Test 3';

% Create and navigate to a unique folder
outputPath = fullfile(ParentFolder, date);
if ~exist(outputPath, 'dir')
    mkdir(outputPath);
end
cd(outputPath);

i = 1;  % Trial counter

while true  % Infinite loop; manually stop with Ctrl+C
    try
        % Generate file name
        if i < 10
            file_name = fullfile(outputPath, sprintf('%s_%s_trial0%d.mat', bat, date, i));
        else
            file_name = fullfile(outputPath, sprintf('%s_%s_trial%d.mat', bat, date, i));
        end
        
        % Initialize DAQ session
        ai = daq("ni");
        ch(1) = addinput(ai, 'Dev1', 'ai0', 'Voltage');  % Mic for vocalization
        ch(2) = addinput(ai, 'Dev1', 'ai1', 'Voltage');  % Mic for echo
        ch(1).TerminalConfig = 'Differential';
        ch(2).TerminalConfig = 'Differential';
        
        % Add external trigger
        addtrigger(ai, "Digital", "StartTrigger", "External", "Dev1/PFI0");
        ai.DigitalTriggers(1).Condition = "RisingEdge";
        ai.NumDigitalTriggersPerRun = 1;
        ai.DigitalTriggerTimeout = 30;  % Reduced timeout for efficiency
        
        % Specify sampling settings
        ai.Rate = 250000;  % 250 kHz
        fprintf('Waiting for trigger - Trial %d...\n', i);
        
        % Record Data
        duration = seconds(2);  % 2-second duration
        [data, timestamps] = read(ai, duration);
        
        % Process Data
        mic_vect = data(:, 1);
        echo_vect = data(:, 2);
        
        mic_data.mic_sig = mic_vect;
        mic_data.echo_sig = echo_vect;
        mic_data.sample_rate = ai.Rate;
        mic_data.trial_num = i;
        
        % Plot the Results
        figure('Name', sprintf('Trial %d', i));
        
        subplot(2,2,1);
        plot(mic_data.mic_sig);
        title('Vocalization Signal (Time Domain)');
        xlabel('Sample Number');
        ylabel('Amplitude');
        
        subplot(2,2,3);
        spectrogram(mic_data.mic_sig, 512, 256, 512, 250000, 'yaxis');
        title('Vocalization Signal (Spectrogram)');
        
        subplot(2,2,2);
        plot(mic_data.echo_sig);
        title('Echo Signal (Time Domain)');
        xlabel('Sample Number');
        ylabel('Amplitude');
        
        subplot(2,2,4);
        spectrogram(mic_data.echo_sig, 512, 256, 512, 250000, 'yaxis');
        title('Echo Signal (Spectrogram)');
        
        % Save Data
        save(file_name, 'mic_data');
        fprintf('Data saved for Trial %d: %s\n', i, file_name);
        
        % Reset and Increment
        daqreset;  % Reset DAQ
        clear ai mic_data mic_vect echo_vect;
        i = i + 1;
        
    catch ME
        warning('Error in Trial %d: %s\nResetting DAQ...', i, ME.message);
        daqreset;  % Ensure clean DAQ reset
    end
end


