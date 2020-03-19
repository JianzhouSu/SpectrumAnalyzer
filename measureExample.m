function measureExample()
%MEASUREEXAMPLE Summary of this function goes here
%   Detailed explanation goes here
    clear;
    instrreset;
%     dbstop if error;
    m = measurement();
    dataAnalyzerExample(m.parameters.dir);
end

