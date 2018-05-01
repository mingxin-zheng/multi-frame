function [res, N] = parseData(projectFolder, jobs, jobIDs, testID, freqGroup, ustFolder, csvFolder)
%% Debug
if nargin < 7
    % Location of Data Files
    ustFolder = '/Volumes/Seagate/cervical model/model_C4/Instron_020617/';
    csvFolder = '/Volumes/Seagate/cervical model/model_C4/Instron_020617/Instron_020617/';
end

%% Determine file location of ust and csv ustFile & csvFile

ID = find(jobIDs==testID,1,'first');
ustFile = jobs(ID).ustFile;
ustFileShort = ustFile(1:strfind(ustFile,'.')-1);

ustFile = [ustFolder num2str(jobs(ID).csvGroup),filesep,jobs(ID).ustFile];
csvFile = [csvFolder num2str(jobs(ID).csvGroup),filesep,ustFileShort,...
            filesep,jobs(ID).csvFile,'.Stop.csv'];
timeDelayFile = [projectFolder,'previous',filesep,'timedelay',filesep,jobs(ID).matFile,'.mat'];
trackingFile = [projectFolder,'previous',filesep,'trackingoutput',filesep,jobs(ID).matFile,'.mat'];

% Check File's Existence, commented for phase 1
if exist(ustFile,'file')~=2 || exist(csvFile,'file')~=2
    % error('File Does Not Exist');
end

if exist(timeDelayFile,'file')~=2 || exist(trackingFile,'file')~=2
    error('Result File Does Not Exist');
end

% Read the data into workspace
timedelaySpace = load(timeDelayFile,'xs','delay');
xs = timedelaySpace.xs;
delay = timedelaySpace.delay;

trackingSpace = load(trackingFile);
data = trackingSpace.data;
Q = trackingSpace.values.Q;
%% Analysis

% xs: time in ultrasound system, unit: second
% timemark: some specfic time marks in the real world(Instron),
% delay: the time delay between the ultrasound and the real world

% Each data has 10 segments of data, each of them lasts for 10 seconds.
% Between the segments, there is a static period

% Find the starting end ending time for the segments, and put them in an
% array of 11 elements.

timemark = 0.5:11.6666:0.5+11.6666*10; % Can be improved here
fr_mark = zeros(size(timemark)); 

for k = 1:11
    fr_mark(k) = findClosest(timemark(k),xs+delay);
end

[~,~,res] = convert_data_struct(data);

% For the frequency group, find the start and end
startingFrame = fr_mark(freqGroup);
endingFrame = fr_mark(freqGroup+1);

% Q contains information about the NCC correlation ratio, but it is
% organized in a very different way

startingDataSegment = sum(sum(Q(1:startingFrame,:)>1))*2;
endingDataSegment = sum(sum(Q(1:endingFrame,:)>1))*2;

res = res(startingDataSegment:endingDataSegment);
N = sum(res>0);
end