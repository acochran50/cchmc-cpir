%% Retrospective Gating Lead Magnitude Generation, 3 Echo

%{
    Authors:    Jinbang Guo, Alex Cochran, Matt Freeman
    Group:      Center for Pulmonary Imaging Research, Cincinnati Children's
    Date:       2018
%}


%% constants

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

file_id = fopen(fullfile(PATH_NAME, 'fid'));
k_data = fread(file_id, [2, inf], 'int32');
fclose(file_id);


%% separate real and complex k-space information

k_data_cmplx = complex(k_data(1, :), k_data(2, :));
k_data_mag = abs(k_data_cmplx);
k_data_mag = reshape(k_data_mag, [128, NUM_PROJ * 3]);
k_data_3_echo = k_data;                                 % why assign again here...
clear kdata;                                            % and then clear here?


%% 