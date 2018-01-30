~~~
%{
  CCHMC CPIR MATLAB Script Format Guidelines

  Alex Cochran, 2018
  These guidelines are meant to be a general set of format specs that can help improve code
  organization and readability. Use them as is reasonable; the ideas listed here aren't meant
  to be draconian.
  
  General rules of thumb:
  
    1. Use good alignment with comments, matrix indices, etc.
    2. Comment as much as you can without muddying your code
    3. Variables should be written using "camel case" (myVar, myArray, myBigStruct, etc.)...
    4. ...but constant variables should be written using all caps (CONST_1, CONST_ARR, etc.)
    5. Variable names should be descriptive
    6. Functions should be given lowercase names to stay in line with MATLAB's style.
       They should also be descriptive and might have a "cpir" tag on them.
    7. Values/variables inside parentheses/brackets (e.g. somefunction(CONST_1, thisVar)
       should always have spaces after commas for readability.
    8. Line lengths should be held to a maximum of 100.
%}


% 'sample.m' Script format:


%% Descriptive Script Title

%{
  Author(s):  Author 1, Author 2...
  Group:      Center for Pulmonary Imaging Research, Cincinnati Children's
  Project:    Project Name
  Date:       Month, Year
%}


%% constants

CONST_1 = ...;                              % comment about CONST_1; units (if necessary)
CONST_2 = ...;                              % comment about CONST_2; units (if necessary)
CONST_3 = ...;                              % comment about CONST_2; units (if necessary)
CONST_4 = [x, y, z];                        % comment about CONST_2; units (if necessary)
CONST_5 = {'fid_1', 'fid_2', 'fid_3'};      % comment about CONST_2; units (if necessary)


%% another section... (leave one space after section title)

% operation 1...
thisVar = 5;
thatVar = thisVar * 20;

% operation 2...
somefunction();

%% a third section...

% operation 3...
anotherfunction();

% operation 4...
plot(thisVar, thatVar);

% leave one blank line at the end of the file
~~~
