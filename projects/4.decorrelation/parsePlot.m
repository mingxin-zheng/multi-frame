function parsePlot(testID, freqGroup, res, N, fsub, ax)

plot_option1 = true;
plot_option2 = true;
save_option = true;

%% plot_options
if plot_option1
    f = figure('Visible','off');
    histogram(res)
    title(['ID: ' num2str(testID) ' (' num2str(freqGroup) ' Hz)']);
    xlabel('res'), ylabel('distribution')
    text(.05,.9,['N=' num2str(N)],'Units','Normalized')
end

if plot_option2
    figure(fsub)
    histogram(ax(freqGroup),res)
    title(['ID: ' num2str(testID) ' (' num2str(freqGroup) ' Hz)']);
    xlabel('res'), ylabel('distribution')
    text(.05,.9,['N=' num2str(N)],'Units','Normalized')
    lin = line(sum(res)/N*[1 1],[0 5000],'Color','r');
    %legend(lin,'avg')
end

if save_option
    % Make new file directory
    newFolder = [cd '/C4Model/Job' num2str(testID) '_Figures'];
    newFig = ['fig' num2str(testID) '-' num2str(freqGroup)];
    newSub = ['sub' num2str(testID)];
    
    if ~exist(newFolder, 'dir')
        mkdir(newFolder);
    end
    saveas(f,fullfile(newFolder, newFig),'jpeg')
    close(f)
    
    if freqGroup == 10
        saveas(ax(freqGroup),fullfile(newFolder, newSub),'jpeg')
    end
end
end