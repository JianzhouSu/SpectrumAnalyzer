function par = parameterSetup()
    %myFun - Description
    %
    % Syntax: par = myFun(input)
    %
    % Long description
    % folder name of results
    par.log = char(['4294A', datestr(now, 30)]);
    % path of result folder
    par.dir = [pwd, '\Results\', par.log, '\'];
    % alias of result folder
    par.outFileName = par.log;

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

    if ~exist(par.dir, 'dir')
        mkdir(par.dir);
    end

    % save par structure
    parTable = struct2table(par);
    writetable(parTable, [par.dir, par.log, '_parameter.csv']);

end
