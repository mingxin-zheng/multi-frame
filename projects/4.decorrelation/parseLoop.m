
clear, close all, format compact
[projectFolder,jobs, jobIDs, excelFile] = parseSetup;
cnt = 1;
resvec = cell(length(jobIDs),11);
resvec(1,:) = {'ID','res1','res2','res3','res4','res5','res6','res7','res8','res9','res10'};

for testID = jobIDs
    cnt = cnt + 1;
    fsub = figure;
    ax = zeros(1,10);
    for freqGroup = 1:10
        [res, N] = parseData(projectFolder, jobs, jobIDs, testID, freqGroup);
        resvec{cnt,1} = testID;     %store ID number in cell
        resvec{cnt,freqGroup+1} = sum(res)/N;   %store average res in cell
        ax(freqGroup) = subplot(4,3,freqGroup);
        fsub = gcf;
        fsub.Position = [566 69 995 711];
        parsePlot(testID, freqGroup, res, N, fsub, ax)
    end
end

xlswrite(fullfile([cd '/C4Model/'],'parseResults.xlsx'),resvec)

%% Plots and Error

% Plot res values vs frequency
data = cell2mat(resvec(2:end,2:end));
figure, hold on
plot(repmat(1:10,length(resvec)-1,1)',data')    %plot all res lines
plot([1:10]',mean(data)','k','LineWidth',1.5)   %plot mean res line
plot(1:10,min(data),'k--','LineWidth',1.5)      %plot min res line
plot(1:10,max(data),'k--','LineWidth',1.5)      %plot min res line
title('C4Model Res vs Frequency')
xlabel('Frequency (Hz)'), ylabel('Res')

% Plot average res value vs frequency
figure, hold on
plot([1:10]',mean(data)','LineWidth',1.5)
err = errorbar(1:10,mean(data),mean(data)-min(data),mean(data)-max(data),'.');
xlim([0 11])
err.Color = 'k';
title('C4Model Average Res')
xlabel('Frequency (Hz)'), ylabel('Average Res')

rng = data(:,1)-data(:,end);        %data range
rngavg = mean(rng);                 %average res change from freq1 to freq10
pcterr = rngavg./mean(data)*100;    %percent error in average res change from mean res values
pcterravg = mean(pcterr);           %average percent error
