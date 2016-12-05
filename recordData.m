function [audioData, savePath ] = recordData(path_save, params, weights, Fs, dur_of_trials, num_of_trials, manualFlag )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


%Initialize paths
            path_save = strcat(path_save,datestr(datetime('now')));
            path_save = strcat(path_save, '.wav');
            
            %Load Parameters and Weights
            load(params);
            load(weights);
            
            %disp(svm.KernelParameters);
            
            %Initialize audio recorder
            myMic = audiorecorder(Fs, 16, 1);
            
            disp((app.ManualStartStopCheckBox));
            %record data
            if (manualFlag == 0)
                recordblocking(myMic, dur_of_trials);
            else
                %app.RecordButton.Visible = 'off';
                record(myMic);
                h = figure(1);
                fig_text = uicontrol('Style', 'text',...
                   'String', 'Close the window to end recording',... %replace something with the text you want
                   'Units','normalized',...
                   'Position', [0.4 0.4 0.1 0.3]); 
                uiwait(h);
                stop(myMic);
            end
            myRecording = getaudiodata(myMic);
            %save(path_save, 'myRecording');    %save raw data
            
            %display the recording
            plot(app.currMicRecording, myRecording);
            app.CurrentStateLabel.Text = 'Done recording...';
            app.CurrentStateLabel.Text = 'Processing...';
            
            %Data Processing
            T = 1/Fs;
            L = myMic.TotalSamples;
            t = (0:L-1)*T;
            Y = fft(myRecording);
            P2 = abs(Y/L);
            P1 = P2(1:L/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            f = Fs*(0:(L/2))/L;
            
            Xtest=getSoundFeatures(myRecording, Fs);
            Xtest=rescale(Xtest', normalization, 0);
            Xtest=[1 Xtest];
            
            [class,scores] = predict(svm,Xtest);
            
            
            %display the recording
            plot(app.currMicRecording, t, myRecording);
            
            %find peaks
            %[pks locs] = findpeaks(P1, f, 'MinPeakProminence', 0);
            %index = max(pks);
            %peak_freq = f(locs);
            
            [val, ind] = max(P1);
            max_freq = f(ind);
            
            %Print Data
            app.SamplingFreqHzEditField.Value = int2str(Fs);
            app.MaxFreqHzEditField.Value = int2str(max_freq);
            app.PeakFreqHzEditField.Value = int2str(Xtest(5));
            plot(app.fftGraph, f, P1);
            app.CurrentStateLabel.Text = 'Done!';
            
            %classification
            if (class == 1)
                app.PatientHealthEditField.Value = 'Healthy';
            else
                app.PatientHealthEditField.Value = 'Not Healthy';
            end            
            app.ConfidenceBoundsEditField.Value = strcat(num2str(scores(1)), ', ', num2str(scores(2)));
            
            %Save the sound file
            audiowrite(path_save,myRecording,Fs);
            app.LoadPathEditField.Value = path_save;

end

