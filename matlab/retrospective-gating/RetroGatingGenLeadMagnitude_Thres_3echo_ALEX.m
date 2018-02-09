%% Retrospective Gating Lead Magnitude Generation, 3 Echo

%{
    Authors:    Jinbang Guo, Alex Cochran, Matt Freeman
    Group:      Center for Pulmonary Imaging Research, Cincinnati Children's
    Date:       2018
%}


%% constants

NUM_PROJ = 29556;
NUM_CUT_PROJ = 0;                                       % cut leading projections
NUM_PROJ_REAL = NUM_PROJ - NUM_CUT_PROJ;
NUM_POINTS = 101;
NUM_SEP = 180;
SEPARATION = round(NUM_PROJ_REAL / NUM_SEP);
THRESH_PCT_EXP = 0.27;
THRESH_PCT_INSP = 0.15;


%% path information

SCRIPT_ID = mfilename('fullpath');
CURR_PATH_NAME = char(pwd);


%% define data path

% DATA_FILES should be a cell array of the data files being gated
% 1 to 3 data files should be selected, in accordance with the 3 possible echo times
% number of data files should be equal to the number of specified echo times

% only prompts for path definition if a data path does not already exist in the workspace
if ~exist('DATA_FILES', 'var')
    while ~exist('DATA_FILE', 'var')
        [DATA_FILE, DATA_PATH] = uigetfile({'*.*', 'All Files (*.*)'}, 'Choose FID');
        if ~isa(DATA_FILE, 'char') % could look for more robust methods
            QUIT = questdlg('No file selected. Quit or continue?', 'No files selected', ...
                'Continue', 'Quit', 'Continue');
            switch QUIT
                case 'Quit'
                    return
                case 'Continue'
                    clear DATA_FILE;
            end
        end
    end
end


%% define output path

% TEST_NAME will be the unique name of the current test
% .\output\TEST_NAME will contain any output files

% define a unique test name (if one doesn't already exist in the workspace)
if ~exist('TEST_NAME', 'var')
    while ~exist('TEST_NAME', 'var')
        TEST_NAME = inputdlg('Test name:');
        if isempty(TEST_NAME)
            clear TEST_NAME;
        end
    end
end

% get output folder location from user input
OUT_DIR = uigetdir;

% only prompts for folder creation if it doesn't already exist
if ~exist(strcat(OUT_DIR, '\', char(TEST_NAME)), 'dir')
    mkdir(strcat(OUT_DIR, '\', char(TEST_NAME)));
    OUT_PATH = strcat(OUT_DIR, '\', char(TEST_NAME));
end


%% echo time specification

% designate the echo times of the images being gated
% units: microseconds
% example: 'Enter echo time 1 [us]: 080' --> echo time 1 is now 80 microseconds or 0.08 ms

if ~exist('ECHO_TIMES', 'var')
    while ~exist('ECHO_TIMES', 'var')
        ECHO_TIMES = transpose(inputdlg({'Echo time 1', 'Echo time 2', 'Echo time 3'}));
        ECHO_TIMES = ECHO_TIMES(~cellfun('isempty', ECHO_TIMES));
        if isempty(ECHO_TIMES)
            clear ECHO_TIMES
        end
    end
end


%% confirm program configuration

% configuration layout


% only prompts if the filenames have not already been confirmed
if ~exist('CONFIRM', 'var')
    while ~exist('CONFIRM', 'var')
        CONFIRM = questdlg('Proceed with gating?', 'Confirm configuration?', 'Yes', 'No', 'Yes');
        if isempty(CONFIRM)
            clear CONFIRM;
        end
    end
    
    % decide whether to proceed
    switch CONFIRM
        case 'Yes'
            disp('CONFIGURATION SUCCESSFUL; PROCEEDING');
        case 'No'
            disp('CONFIGURATION HALTED; ABORTING');
            return % exit script
    end
end

%% data read

% open file and extract k-space information, set by set
fileID = fopen(fullfile(DATA_PATH, DATA_FILE));
kData = fread(fileID, [2, inf], 'int32');
fclose(fileID);

% separate real and complex k-space information
kDataCmplx = complex(kData(1, :), kData(2, :));
kDataMag = abs(kDataCmplx);
kDataMag = reshape(kDataMag, [128, NUM_PROJ * 3]);
kData3Echo = kData;                                     % why assign again here...
clear kData;                                            % and then clear here?


%% retrospective gating subroutine

disp('STARTING RETROSPECTIVE GATING ROUTINE');

for echoIndex = 1:3
    
    tempMag = kData3Echo(:, echoIndex:3:NUM_PROJ * 3 - 3 + echoIndex);
    for index = 1:NUM_PROJ
        kData(:, (index - 1) * 128 + 1:index * 128) = ...
            kData3Echo(:, (echoIndex - 1) * 128 + 1 + (index - 1) * 128 * 3: ...
            echoIndex * 128 + (index-1) * 128 * 3);
    end
    
    magnitudeLeading = squeeze(tempMag(20, (NUM_CUT_PROJ + 1):NUM_PROJ));
    
    selectVectorExp = zeros(1, NUM_PROJ_REAL);
    selectVectorInsp = zeros(1, NUM_PROJ_REAL);
    
    subplot(3, 1, echoIndex);
    plot(magnitudeLeading, 'o', 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'w', 'MarkerSize', 5);
    
    for i = 1:NUM_SEP;
        minPeakHeight = (max(magnitudeLeading((i - 1) * SEPARATION + 1:i * SEPARATION)) + ...
            min(magnitudeLeading((i - 1) * SEPARATION + 1:i * SEPARATION))) / 2;
        
        [peaks, ~] = findpeaks(magnitudeLeading((i - 1) * SEPARATION + 1:i * SEPARATION), ...
            'MINPEAKHEIGHT', minPeakHeight);
        meanMax = max(peaks);
    
        [peaks, ~] = findpeaks(-magnitudeLeading((i - 1) * SEPARATION + 1:i * SEPARATION), ...
            'MINPEAKHEIGHT', -minPeakHeight);
        meanMin = -max(peaks);
    
        threshold = meanMax - THRESH_PCT_EXP * (meanMax - meanMin);
        selectVectorExp(1, (i - 1) * SEPARATION + 1:i * SEPARATION) = ...
            magnitudeLeading((i - 1) * SEPARATION + 1:i * SEPARATION) > threshold;
        
        threshold = meanMin - THRESH_PCT_INSP * (meanMax - meanMin);
        selectVectorInsp(1, (i - 1) * SEPARATION + 1:i * SEPARATION) = ...
            magnitudeLeading((i - 1) * SEPARATION + 1:i * SEPARATION) < threshold;
    end
    
    selectVectorExp = logical(selectVectorExp);
    selectVectorInsp = logical(selectVectorInsp);
    
    plot(magnitudeLeading, 'o', 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'w', 'MarkerSize', 5);
    hold on;
    xlabel(strcat(['FID # [TE: ', char(ECHO_FID_ARR(echoIndex)), ' [\mus]']), 'FontSize', 10, ...
        'FontWeight', 'bold', 'Color', 'k');
    ylabel('Phase [radians]', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
    title('Leading phase of each spoke', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k');
    
    magnitudeExp = magnitudeLeading(selectVectorExp);
    locsExp = find(selectVectorExp);
    plot(locsExp, magnitudeExp, 'ro');
    
    magnitudeInsp = magnitudeLeading(selectVectorInsp);
    locsInsp = find(selectVectorInsp);
    plot(locsInsp, magnitudeInsp, 'gs');
    
    hold off
    xlim([1, 1000]);
    
    % reshape k-space information
    kData = reshape(kData, [2 128 NUM_PROJ]);
    kData = kData(:, :, NUM_CUT_PROJ + 1:NUM_PROJ);
    
    % write expiration data to file
    kDataExp = kData(:, :, selectVectorExp);
    numProjExp = size(kDataExp, 3);
    fileID = fopen(fullfile(OUT_PATH, strcat(['fid_expiration', ...
        char(ECHO_TIMES{echoIndex})])), 'w');                              % CHANGED DESTINATION
    fwrite(fileID, kDataExp, 'int32');
    fclose(fileID);
    
    % write trajectory data to file
    fileID = fopen(fullfile(OUT_PATH, strcat(['traj' ...
        char(ECHO_TIMES{echoIndex})])), 'w');                              % CHANGED DESTINATION
    trajectory = reshape(fread(fileID, [3, inf], 'double'), [3 NUM_POINTS, NUM_PROJ * 3]);
    fclose(fileID);
    
    % extract expiration trajectory data
    trajectory3Echo = trajectory;
    clear trajectory;
    trajectory = trajectory3Echo(:, :, NUM_CUT_PROJ + echoIndex:3:NUM_PROJ * 3 - 3 + echoIndex);
    trajectoryExp = trajectory(:, :, selectVectorExp);
    
    % write expiration trajectory data to file
    fileID = fopen(fullfile(OUT_PATH, strcat(['traj_expiration', ...
        char(ECHO_TIMES{echoIndex})])), 'w');                              % CHANGED DESTINATION
    fwrite(fileID, trajectoryExp, 'double');
    fclose(fileID);
    
    % write inspiration data to file
    kDataInsp = kData(:, :, selectVectorInsp);
    numProjInsp = size(kDataInsp, 3);
    fileID = fopen(fullfile(OUT_PATH, strcat(['fid_inspiration', ...
        char(ECHO_TIMES{echoIndex})])), 'w');                              % CHANGED DESTINATION
    fwrite(fileID, kDataInsp, 'int32');
    fclose(fileID);
    
    % extract inspiration trajectory data
    trajectoryInsp = trajectory(:, :, selectVectorInsp);
    
    % write inspiration trajectory data to file
    fileID = fopen(fullfile(OUT_PATH, strcat(['traj_inspiration', ...
        char(ECHO_TIMES{echoIndex})])), 'w');                              % CHANGED DESTINATION
    fwrite(fileID, trajectoryInsp, 'double');
    fclose(fileID);
end

% set figure position
set(gcf, 'Position', [50 80 1420 680]);

disp('RETROSPECTIVE GATING ROUTINE COMPLETE');
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    