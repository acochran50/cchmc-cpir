
% 
% if ~exist('TEST_NAME', 'var')
%     while ~exist('TEST_NAME', 'var')
%         TEST_NAME = input('Enter a test name: ', 's');
%         if isempty(TEST_NAME)
%             clear TEST_NAME;
%         end
%     end
% end

TEST_NAME = 'geronimo';

% only prompts for folder creation if it doesn't already exist
if ~exist(strcat('.\output\', TEST_NAME), 'dir')
    mkdir(strcat('.\output\', TEST_NAME));
end