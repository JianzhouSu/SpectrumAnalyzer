%% Testing example for Agilent 4294A and Prologix GPIB-USB controller.
% Ignoring benign reading warning, use ++auto 1 to read returns from Agilent 4294a.
% Cautions shown on 4294A's screen can be ignored.
% Terminator of serial port message is LF(ascii 10).

%% Matlab workspace and device initialization.
%Clear Workspace
clear;
% reset all instruments connected to matlab.
instrreset;

%% Parameters Setups
par = parameter_setup();

%% Setups serial communication between PC and Prologix.
% ia stands for impedance analyzer
% According to prologix, baud rate doesn't matters.
ia = serial('COM5','BaudRate',115200,'Terminator','LF');
% Sets terminator of message is LF(ascii 10)
% configureTerminator(ia, "LF");
% Communication timeout setup (unit: seconds)
ia.Timeout = 15;
% Input buffer size setup
ia.InputBufferSize = 10*20001;

%% Start Communication

% setup prologix GPIB-USB controller
setup_prologix(ia);

% Query ID number to test communications
fprintf(ia, "*IDN?");
% read returns
idn = fgets(ia);
disp(idn);

init_4294a(ia, par);
pause(0.5);
freq_vec = linspace(par.leftFq, par.rightFq, par.NOP);

keyHandle = uicontrol(...
    'Style', 'pushbutton', ...
    'String', 'Stop', ...
    'Position', [80, 5, 50, 20], ...
    'Callback', 'delete(gco)');
timeZero = tic;
time_vec = []

while ishandle(keyHandle)
    [mag, phs] = one_sweep(ia, par);
    plot_mag_phs(freq_vec, mag, phs);
    hold on
    
    timeNow = toc(timeZero);
    time_vec = [time_vec timeNow]
    
    % save freq array
    dlmwrite([par.dir, par.log, '_freq.csv'],[timeNow, freq_vec],'delimiter', ',', '-append'); % append mode
    % save mag parts
    dlmwrite([par.dir, par.log, '_real.csv'],[timeNow, mag.'],'delimiter', ',','-append');
    % save phs parts
    dlmwrite([par.dir, par.log, '_phs.csv'],[timeNow, phs.'],'delimiter',',','-append');
    % analyze data
    [resf,fwhm,Q] = analyze(mag,phs,freq_vec);
    %Plot Analysis
    plotana(time_vec,resf,fwhm,Q)
    %Save analysis
    dlmwrite([par.dir,par.log,'_analysis.csv'],[timeNow,resf,fwhm,Q],'delimiter',',','-append');
end
    % fprintf(ia, "SING");

% disp(wait_4294a(ia, 'Sweep Finished: '));

% END OF CODE------------------------------------------------------------------
disp("END OF CODE");

%% FUNCTIONS
%

function par = parameter_setup()
    %myFun - Description
    %
    % Syntax: par = parameter_setup()
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

function setup_prologix(ia)
    %setup_prologix - Description
    %
    % Syntax:  setup_prologix(input)
    %
    % Long description
    fopen(ia);
    fprintf(ia, "++mode 1");
    fprintf(ia, "++addr 17");
    fprintf(ia, "++auto 1");
    fprintf(ia, "++eoi 1");
    fprintf(ia, "++eos 2");
    fprintf(ia, "read_tmo_ms 3000");
end

function stats = wait_4294a(ia, text)
    %myFun - Description
    %
    % Syntax: stats = wait_4294a(ia, text)
    %
    % Long description
    % necessary delay
    pause(0.1);
    fprintf(ia, '*OPC?');

    if ~isempty(fgets(ia))
        stats = [text, 'True'];
    else
        stats = [text, 'False'];
    end

end

function init_4294a(ia, par)
    %myFun - Description
    %
    % Syntax: init_4294a(par)
    %
    % reset and setup parameters

    % 4294A reset
    % '*RST':Triggers a reset to the preset state. Although this preset state is almost the same as that of
    % the reset result with the PRES? command on page 404, there are some differences as
    % follows. (No query)
%     fprintf(ia, '*RST');
    % '*CLS': Clears the error queue, Status Byte Register, Operation Status Register, Standard Event
    % Status Register, and Instrument Event Status Register.
%     fprintf(ia, '*CLS');
    % '*OPC': Makes the setting, when the execution of all overlap commands (refer to *WAI on page
    % 262) is completed, to set the OPC bit (bit 0) of the Standard Event Status Register. (No
    % query).
    % fprintf(ia, '*OPC');
    % wait for finished
    disp(wait_4294a(ia, 'Init Finished: '));
    %Sets Measurement Parameter
    fprintf(ia,'MEAS{IRIM}');
    % Sets oscillation
    fprintf(ia, ['POWE ', num2str(par.osc_level) ' V']);
    % Sets the sweep range start value. P444
    fprintf(ia, ['STAR ', num2str(par.leftFq), 'HZ']);
    % Sets the sweep range stop value. P446
    fprintf(ia, ['STOP ', num2str(par.rightFq), 'HZ']);
    % Sets the bandwidth. To set the bandwidth of each segment when creating the list sweep
    % table, also use this command. P274
    fprintf(ia, 'BWFACT 2');
    %   Sets the transfer format for reading array data to the ASCII format (preset state). For details
    %  about transfer formats, refer to "Data Transfer Format" on page 78. (No query)
    fprintf(ia, 'FORM4');
    % sets number of points of each sweep
    fprintf(ia, ['POIN ', num2str(par.NOP)]);
    % Enable average measurement points
    fprintf(ia, 'PAVER ON');
    % Points averaging factor
    fprintf(ia, ['PAVERFACT ', num2str(par.p_aver)]);
    % Measurement Parameter
    
end

function [mag, phs] = one_sweep(ia, par)
    %myFun - Description
    %
    % Syntax: mag, phs = one_sweep(ia, par)
    %
    % Long description
    fprintf(ia, 'HOLD');
    fprintf(ia, 'TRGS INT');
    fprintf(ia, 'SING');
    pause(10);
    disp(wait_4294a(ia, 'Sweep Finished: '));
    pause(0.1);
    fprintf(ia, 'TRAC A');
%     fprintf(ia, 'FMT LOGY');
    fprintf(ia, 'AUTO');
    fprintf(ia, 'OUTPDTRC?');
    mag = str2double(split(fgets(ia), ','));
    mag = mag(1:2:end);
    fprintf(ia, 'TRAC B');
    %     fprintf(ia, 'FMT LINY');
    fprintf(ia, 'AUTO');
    fprintf(ia, 'OUTPDTRC?'); 
    phs = str2double(split(fgets(ia), ','));
    phs = phs(1:2:end);
    disp(wait_4294a(ia, 'Read Data Finished: '));
end

function plot_mag_phs(freq_vec, mag, phs)
%     f1 = figure('Position', [200, 200, 500, 500]);
    figure(1);
    subplot(1, 2, 1);
    loglog(freq_vec, mag);
    xlabel('Frequency (Hz)');
    ylabel('Impedance Real Part (\Omega)');
    hold on;
    grid on;
    subplot(1, 2, 2);
    semilogx(freq_vec, phs);
    xlabel('Frequency (Hz)');
    ylabel('Imaginary Part (\Omega)');
    hold on;
    grid on;

end

function [resf,fwhm,Q] = analyze(real,img,freq_vec)
    
    % Find RF
    RFindex = find(real== max(real));
    resf = freq_vec(RFindex);
    
    %Find FWHM Bandwidth
    halfMax = (min(real) + max(real)) / 2;
    % Find where the data first drops below half the max.
    index1 = find(real >= halfMax, 1, 'first');
    % Find where the data last rises above half the max.
    index2 = find(real >= halfMax, 1, 'last');
    fwhm = freq_vec(index2) - freq_vec(index1);
    % Find Q
    Q = resf/fwhm;
    
end

function plotana(time_vec,resf,fwhm,Q)
    figure(2);
    subplot(3, 1, 1);
    plot(time_vec, resf);
    xlabel('Time(s)');
    ylabel('Resonant Frequency(Hz)');
    grid on;
    subplot(3, 1, 2);
    plot(time_vec, fwhm);
    xlabel('Time(s)');
    ylabel('Bandwidth(Hertz)');
    grid on;
    subplot(3,1,3)
    plot(time_vec, Q);
    xlabel('Time(s)');
    ylabel('Quality Factor');
    grid on
    legend;
    drawnow;
end 