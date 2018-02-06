%% Retrospective Gating Lead Magnitude Generation, 3 Echo

%{
    Authors:    Jinbang Guo, Alex Cochran, Matt Freeman
    Group:      Center for Pulmonary Imaging Research, Cincinnati Children's
    Date:       2018
%}


%% set up logging interface

% uses class defined in log4m.m
LOGGER = log4m.getLogger('logfile.log');
LOGGER.setLogLevel(LOGGER.DEBUG);
LOGGER.setCommandWindowLevel(LOGGER.WARN);


%% constants

SCRIPT_ID = mfilename('fullpath');
PATH_NAME = char(pwd);
NUM_PROJ = 29556;
NUM_CUT_PROJ = 0;                                       % cut leading projections
NUM_PROJ_REAL = NUM_PROJ - NUM_CUT_PROJ;
NUM_POINTS = 101;
NUM_SEP = 180;
SEPARATION = round(NUM_PROJ_REAL / NUM_SEP);
THRESH_PCT_EXP = 0.27;
THRESH_PCT_INSP = 0.15;
ECHO_FID_ARR = {'0800', '2000', '4000'};


%% open file and extract k-space information

fileID = fopen(fullfile(PATH_NAME, 'fid'));
kData = fread(fileID, [2, inf], 'int32');
fclose(fileID);


%% separate real and complex k-space information

kDataCmplx = complex(kData(1, :), kData(2, :));
kDataMag = abs(kDataCmplx);
kDataMag = reshape(kDataMag, [128, NUM_PROJ * 3]);
kData3Echo = kData;                                     % why assign again here...
clear kData;                                            % and then clear here?


%% ???

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
    fileID = fopen(fullfile(PATH_NAME, strcat(['fid_expiration', ...
        char(ECHO_FID_ARR(echoIndex))])), 'w');
    fwrite(fileID, kDataExp, 'int32');
    fclose(fileID);
    
    % write trajectory data to file
    fileID = fopen(fullfile(PATH_NAME, 'traj'));
    trajectory = reshape(fread(fileID, [3, inf], 'double'), [3 NUM_POINTS, NUM_PROJ * 3]);
    fclose(fileID);
    
    % extract expiration trajectory data
    trajectory3Echo = trajectory;
    clear trajectory;
    trajectory = trajectory3Echo(:, :, NUM_CUT_PROJ + echoIndex:3:NUM_PROJ * 3 - 3 + echoIndex);
    trajectoryExp = trajectory(:, :, selectVectorExp);
    
    % write expiration trajectory data to file
    fileID = fopen(fullfile(PATH_NAME, strcat(['traj_expiration', ...
        char(ECHO_FID_ARR(echoIndex))])), 'w');
    fwrite(fileID, trajectoryExp, 'double');
    fclose(fileID);
    
    % write inspiration data to file
    kDataInsp = kData(:, :, selectVectorInsp);
    numProjInsp = size(kDataInsp, 3);
    fileID = fopen(fullfile(PATH_NAME, 'fid_inspiration'), 'w');
    fwrite(fileID, kDataInsp, 'int32');
    fclose(fileID);
    
    % extract inspiration trajectory data
    trajectoryInsp = trajectory(:, :, selectVectorInsp);
    
    % write inspiration trajectory data to file
    fileID = fopen(fullfile(PATH_NAME, 'traj_inspiration'), 'w');
    fwrite(fileID, trajectoryInsp, 'double');
    fclose(fileID);
end

% set figure position
set(gcf, 'Position', [50 80 1420 680])

LOGGER.debug('main'

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    