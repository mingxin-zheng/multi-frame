function [res, N] = dataParser(testID, freqGroup, ustFolder, csvFolder)

% This function reads the test matrix data, gives the file information and
% perform simple analysis on it.

plot_option = false;

%% Debug
if nargin < 4
    % Location of Data Files
    ustFolder = '/Volumes/Seagate/cervical model/model_C4/Instron_020617/';
    csvFolder = '/Volumes/Seagate/cervical model/model_C4/Instron_020617/Instron_020617/';
end

%%  Paths and File Location

% Folder Structure
% root
% - projects
%   - decorrelation
%       -previous
%           -timedelay
%           -trackingoutput
%       -decorrelation.xlsx (sheet name:'C4Model')
%       -dataParser.m
% - scripts (where decorrelationDataParser.m is located)
%   - utilites
%       -convert_data_struct.m
% *external
% ustFolder & csvFolder

% Location of Script and DataSheets Folders
projectFolder = mfilename('fullpath');
idcs = strfind(projectFolder,filesep);
projectFolder = projectFolder(1:idcs(end));
scriptFolder = [projectFolder(1:idcs(end-2)),'scripts',filesep];
utilitiesFolder = [scriptFolder, 'utilities'];
addpath(utilitiesFolder);

excelFile = 'decorrelation.xlsx';

% Read and Parse XLSX file
[~,~,raw] = xlsread(excelFile,'C4Model');

% Construct Structs from "raw"
    % contents(column) in "raw": ID(1), Amplitude(2), Angle(3), ustFile(4), 
    % method(5), roi(6), matFile(7), csvGroup(8), csvFile(9).
f = raw(1,1:end); % fields
v = raw(2:end,1:end); % values
jobs = struct(  f{1},v(:,1),f{2},v(:,2),f{3},v(:,3),... 
                f{4},v(:,4),f{5},v(:,5),f{6},v(:,6),...
                f{7},v(:,7),f{8},v(:,8),f{9},v(:,9));
jobIDs = zeros(1,numel(jobs));
for k = 1:numel(jobs)
    % 'jobs(1:n).method=[10 20 169 34];'
    jobIDs(k) = jobs(k).ID;
    eval(['jobs(',num2str(k),').',f{5},'=',jobs(k).method,';']);
    % 'jobs(1:n).roi=[10 20 169 34];'
    eval(['jobs(',num2str(k),').',f{6},'=',jobs(k).roi,';']);
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

% timemark = 0.5:11.6666:0.5+11.666610; % Can be improved here
tm_start = 1.5:11.666:1.5+11.666*9;
tm_end = 10.5:11.666:10.5+11.666*9;

% fr_mark = zeros(size(timemark));
fm_start = zeros(size(tm_start));
fm_end = zeros(size(tm_end));

for k = 1:10
% fr_mark(k) = findClosest(timemark(k),xs+delay);
fm_start(k) = findClosest(tm_start(k),xs+delay);
fm_end(k) = findClosest(tm_end(k),xs+delay);
end

[~,~,res] = convert_data_struct(data);

% For the frequency group, find the start and end
% startingFrame = fr_mark(freqGroup);
startingFrame = fm_start(freqGroup);
% endingFrame = fr_mark(freqGroup+1);
endingFrame =fm_end(freqGroup);

% Q contains information about the NCC correlation ratio, but it is
% organized in a very different way

startingDataSegment = sum(sum(Q(1:startingFrame,:)>1))*2;
endingDataSegment = sum(sum(Q(1:endingFrame,:)>1))*2;

res = res(startingDataSegment:endingDataSegment);
N = sum(res>0);

%% plot_option
if plot_option
    figure, 
    histogram(res);
    title(['N=',num2str(N), ', Total=', num2str(numel(res))]);
end
end