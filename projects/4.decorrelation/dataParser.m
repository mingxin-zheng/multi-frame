clc
clear

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

% Location of Large Data Files
ustFolder = '/Volumes/Seagate/cervical model/model_C4/Instron_020617/';
csvFolder = '/Volumes/Seagate/cervical model/model_C4/Instron_020617/Instron_020617/';

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

ID = find(jobIDs==40,1,'first');
ustFile = jobs(ID).ustFile;
ustFileShort = ustFile(1:strfind(ustFile,'.')-1);

ustFile = [ustFolder num2str(jobs(ID).csvGroup),filesep,jobs(ID).ustFile];
csvFile = [csvFolder num2str(jobs(ID).csvGroup),filesep,ustFileShort,...
            filesep,jobs(ID).csvFile,'.Stop.csv'];
timeDelayFile = [projectFolder,'previous',filesep,'timedelay',filesep,jobs(ID).matFile,'.mat'];
trackingFile = [projectFolder,'previous',filesep,'trackingoutput',filesep,jobs(ID).matFile,'.mat'];

% Check File's Existence
if exist(ustFile,'file')~=2 || exist(csvFile,'file')~=2
    % error('File Does Not Exist');
end

if exist(timeDelayFile,'file')~=2 || exist(trackingFile,'file')~=2
    error('Result File Does Not Exist');
end

%% Determine the starting frame and ending frame

timedelaySpace = load(timeDelayFile,'xs','delay');
xs = timedelaySpace.xs;
delay = timedelaySpace.delay;
timemark = 0.5:11.6666:0.5+11.6666*10; %n-1elements
fr_mark = zeros(size(timemark)); % n+1 elements

for k = 1:11
    fr_mark(k) = findClosest(timemark(k),xs+delay);
end

trackingSpace = load(trackingFile);
data = trackingSpace.data;
Q = trackingSpace.values.Q;
[~,~,res] = convert_data_struct(data);


%% 

freqGroup = 5;
startingFrame = fr_mark(freqGroup);
endingFrame = fr_mark(freqGroup+1);

startingDataSegment = sum(sum(Q(1:startingFrame,:)>1))*2;
endingDataSegment = sum(sum(Q(1:endingFrame,:)>1))*2;


res = res(startingDataSegment:endingDataSegment);
N = sum(res>0);
figure
histogram(res)
title(['N=',num2str(N)]);