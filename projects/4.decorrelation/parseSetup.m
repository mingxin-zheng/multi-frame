function [projectFolder,jobs, jobIDs, excelFile] = parseSetup
% This function reads the test matrix data.

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
f = raw(1,1:end);       % fields
v = raw(2:end,1:end);	% values
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

end