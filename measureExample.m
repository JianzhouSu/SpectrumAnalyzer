function measureExample()
%measureExample Summary of this function goes here
%   Detailed explanation goes here
    clear;
    instrreset;
    m = measurement();
    dataAnalyzerExample(m.parameters.dir);
end

