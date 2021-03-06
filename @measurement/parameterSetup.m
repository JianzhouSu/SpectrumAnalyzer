function par = parameterSetup()
    %parameterSetup - Set the parameter for carrying experiments.
    %
    % Syntax: par = parameterSetup()
    %
    % Some parameters about experiments like com port, measuring format, frequencies

    % device com port
    par.comPort = 'COM5';
    % folder name of results
    par.log = char(['4294A', datestr(now, 30)]);
    % path of result folder
    par.dir = [pwd, '\Results\', par.log, '\'];
    % alias of result folder
    par.outFileName = par.log;

    % measure format
    % IRIM : real part(R) and imagine part(X)
    % IMPH : impedance magnitude(Z) and phase
    % AMPH : admittance magnitude(Y) and phase
    % ARIM : conductance(G) and susceptance(B)
    par.format = 'IRIM';
    % start frequency of sweep
    par.leftFq = 32500;
    % stop frequency of sweep
    par.rightFq = 33000;
    % number of points of sweep
    par.NOP = 201;
    % oscillation level (unit: volts)
    par.osc_level = 0.1;
    % average on every measurement points
    par.p_aver = 8;

    % if directory not exist, create one.
    if ~exist(par.dir, 'dir')
        mkdir(par.dir);
    end

    % save par structure
    parTable = struct2table(par);
    writetable(parTable, [par.dir, par.log, '_parameter.csv']);

end
