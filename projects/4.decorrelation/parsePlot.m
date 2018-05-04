function parsePlot(testID, freqGroup, res, N, fsub, ax)
% parsePlot makes a histogram subplot of res for each frequency group.
% The function also saves the subplot if save_option is true.

save_option = true;

%% plot_options

figure(fsub)
histogram(ax(freqGroup),res)
title(['ID: ' num2str(testID) ' (' num2str(freqGroup) ' Hz)']);
xlabel('res'), ylabel('distribution')
text(.05,.9,['N=' num2str(N)],'Units','Normalized')
line(sum(res)/N*[1 1],ylim,'Color','r')

if save_option
    % Make new file directory
    newFolder = [cd '/C4Model/Figures'];
    newFig = ['fig_' num2str(testID)];
    
    if ~exist(newFolder, 'dir')
        mkdir(newFolder);
    end
    
    if freqGroup == 10
        saveas(ax(freqGroup),fullfile(newFolder, newFig),'jpeg')
    end
end
end