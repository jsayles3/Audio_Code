




%%%Recording mic data using a manual trigger (newer daq code)
%Adi 10/27/22 edited by Michael Wilkinson
%Adi 11/16/22





%% Start Loop
a=datetime('now','Format','yyyyMMdd');
date=strcat(num2str(a.Year),'0',num2str(a.Month),num2str(a.Day));
bat= 'BAT_ID';
ParentFolder = 'C:\Users\jsayles3\Desktop\Mic Test 3';
mkdir(ParentFolder,date)
pathh=strcat('C:\Users\jsayles3\Desktop\Mic Test 3\',date);
cd(pathh)

i=1;
while i > -1 %No limit to number of trials

if i<10
    file_name=strcat(bat,'_', date, '_trial0', num2str(i), '.mat');
else
    file_name=strcat(bat,'_', date, '_trial', num2str(i), '.mat');  
end 

%%Creating a new session
ai= daq('ni');

%%Creating Input Channels
ch(1)=addinput(ai,'Dev1','ai0','Voltage'); % microphone for vocalization
ch(2)=addinput(ai,'Dev1','ai1','Voltage'); % microphone for echo
ch(1).TerminalConfig = 'Differential';
ch(2).TerminalConfig = 'Differential';

%Adding an external trigger

addtrigger(ai,"Digital","StartTrigger","External","Dev1/PFI0");
ai.DigitalTriggers(1).Condition = "RisingEdge";
ai.NumDigitalTriggersPerRun=1;
ai.DigitalTriggerTimeout = 300000;

%%Specifying Duration and Sampling Rate
  
ai.Rate = 250000;
fprintf('Trigger for Trial %d\n',i)

%Get Data
[data,timestamps] = read(ai,seconds(2)); %RECORD LENGTH
mic_vect= data(1:end,1);
echo_vect=data(1:end,2);

%Save Data
mic_data.mic_sig= mic_vect;
mic_data.mic_sig= table2array(mic_data.mic_sig);
mic_data.echo_sig= echo_vect;
mic_data.echo_sig= table2array(mic_data.echo_sig);
mic_data.sample_rate= ai.Rate;
mic_data.trial_num=i;
figure()

% Plot the vocalization signal (mic_sig) in the left two subplots
subplot(2,2,1)
plot(mic_data.mic_sig)
title('Vocalization Signal (Time Domain)')
xlabel('Sample Number')
ylabel('Amplitude')

subplot(2,2,3)
spectrogram(mic_data.mic_sig,512,256,512,250000,'yaxis')
title('Vocalization Signal (Spectrogram)')

% Plot the echo signal (echo_sig) in the right two subplots
subplot(2,2,2)
plot(mic_data.echo_sig)
title('Echo Signal (Time Domain)')
xlabel('Sample Number')
ylabel('Amplitude')

subplot(2,2,4)
spectrogram(mic_data.echo_sig,512,256,512,250000,'yaxis')
title('Echo Signal (Spectrogram)')
save(file_name,"mic_data");
clearvars mic_vect mic_data echo_vect
daqreset

i=i+1;
end





















