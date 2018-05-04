function parseLoop2
clc, clear, close all, format compact
cnt = 0;
plotOption = true;

[projectFolder,jobs,jobIDs,excelFile] = parseSetup;

resvec = zeros(length(jobIDs),11);

for testID = jobIDs
    cnt = cnt + 1;
    if plotOption
        figure
        ax = zeros(1,10);
    end
    for freqGroup = 1:10
        [res, N] = parseData(projectFolder, jobs, jobIDs, testID, freqGroup);
        resvec(cnt,1) = testID;     %store ID number in first column
        resvec(cnt,freqGroup+1) = sum(res)/N;   %store average res
        if plotOption
            ax(freqGroup) = subplot(4,3,freqGroup);
            fsub = gcf;
            fsub.Position = [566 69 995 711];
            parsePlot(testID, freqGroup, res, N, fsub, ax)
        end
    end
end

save([projectFolder '\parseResults2.mat'],'resvec')
resvec = resvec(:,2:end);   %remove jobID from beginning of file
xlswrite([projectFolder excelFile],{'res (1 Hz)','res (2 Hz)',...
    'res (3 Hz)','res (4 Hz)','res (5 Hz)','res (6 Hz)','res (7 Hz)',...
    'res (8 Hz)','res (9 Hz)','res (10 Hz)'},'C4ModelResults','J1:S11')
xlswrite([projectFolder excelFile],resvec,'C4ModelResults','J2:S73')

%% Plots and Error
%if plotOption
    % Reorganize res data by amplitude and frequency data(res,freq,amp)
    data = zeros(18,10,4);
    velocity = zeros(10,4);
    for amp = 1:4
        for freq = 1:10
            data(:,freq,amp) = resvec(amp:4:end,freq);  %res values for each amplitude
            resavg = squeeze(mean(data));
            velocity(freq,amp) = amp*freq*4;
        end
    end
    
    % Plot average res vs velocity
    figure
    plot(velocity,resavg)
    title('Res vs velocity')
    xlabel('Velocity'),ylabel('Average res')
    legend('1mm','2mm','3mm','4mm')

    % Plot res values vs frequency
    figure, hold on
    plot(repmat([1:10]',1,4),resavg)
    title('Res vs Frequency')
    xlabel('Frequency (Hz)'),ylabel('Average res')
    legend('1mm','2mm','3mm','4mm')

    %{
    plot(repmat(1:10,length(resvec),1)',resvec')    %plot all res lines
    plot([1:10]',mean(resvec)','k','LineWidth',1.5)   %plot mean res line
    plot(1:10,min(resvec),'k--','LineWidth',1.5)      %plot min res line
    plot(1:10,max(resvec),'k--','LineWidth',1.5)      %plot min res line
    title('C4Model Res vs Frequency')
    xlabel('Frequency (Hz)'), ylabel('Res')

    % Plot average res value vs frequency
    figure, hold on
    plot([1:10]',mean(resvec)','LineWidth',1.5)
    err = errorbar(1:10,mean(resvec),mean(resvec)-min(resvec),mean(resvec)-max(resvec),'.');
    xlim([0 11])
    err.Color = 'k';
    title('C4Model Average Res')
    xlabel('Frequency (Hz)'), ylabel('Average Res')
    %}
%end

rng = range(resavg);            %data range for each amplitude
pcterr = rng./mean(resavg)*100; %percent error of res range from mean res values
save('vars.mat','resvec','rng','pcterr')
end