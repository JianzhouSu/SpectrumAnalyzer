%% Example Title
function dataAnalyzerExample(pathInput)
    % Summary of example objective
    clear;
    warning('off', 'all');
    %% Section 1 Title
    % Description of first code block
    if nargin < 1

        a = analyzer();
    else
        a = analyzer(pathInput);
    end

    %% Section 2 load file
    % Description of second code block
    % [timeArray, freqArray, realPartArray] = loadData(a.folder);
    a.loadFile();

    %% Section 3 use sweep to find base line
    % sweepSize = size(a.data1Array);

    % sweepArray = sweep(zeros(sweepSize(1)),zeros(sweepSize(2)),zeros(sweepSize(2)));
    for idxSweep = (1:size(a.data1Array, 1))
        sweepArray(idxSweep) = sweep(a.timeArray(idxSweep), a.freqArray(idxSweep, :), a.data1Array(idxSweep, :));
    end

    figure();
    axHandle = gca;

    rf = zeros(size(a.timeArray));
    bw = zeros(size(a.timeArray));
    qf = zeros(size(a.timeArray));

    for idxSweep = (1:size(a.data1Array, 1))
        sweepArray(idxSweep).baselineCorrect(2);

        %     sweepArray(idxSweep).smoothValues();
        axHandle = sweepArray(idxSweep).plot2d(axHandle);
        bw(idxSweep) = sweepArray(idxSweep).getBandwidth();
        rf(idxSweep) = sweepArray(idxSweep).getResonateFreq();
        qf(idxSweep) = sweepArray(idxSweep).getQFactor();
    end

    title(a.name);
    grid on;
    legend;
    xlabel('frequency(Hz)');
    ylabel('Real part(ohms)');
    a.saveCalibratedFig();
    
    a.saveResult(rf, bw, qf);
    a.plotResult(rf, bw, qf);
    a.saveResultFig();
end
