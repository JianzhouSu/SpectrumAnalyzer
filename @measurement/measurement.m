classdef measurement < handle
    %MEASUREMENT class for measurement.
    %   Analyzer will be created by input path, load data from "*_freq.csv","*_real.csv" and "*_imag.csv".
    %   Currently, only data1(real part) will be process, no analysis data from imagine part.

    properties
        parameters; % parameter structure including frequencies, data format
        device; % class of device like 4294A@A4294A
        figHandle; % figure handle for real time plotting sweeps
        data1Axis; % axis handle for real time plotting data1
        data2Axis; % axis handle for real time plotting data2
    end

    methods

        function obj = measurement()
            %measurement Constructor of measurement class.
            %   This constructor will also include initialization and continuously query sweeps.

            % parameter setup;
            obj.parameters = obj.parameterSetup();
            % transit device class to property
            obj.device = A4294A(obj.parameters.comPort);
            % measurement initialization
            obj.init();
            % continuously query sweeps.
            obj.run();

            % END OF CODE
            disp("END OF MEASUREMENT.");
        end

        function init(obj)
            % INIT using parameter properties to set device accordingly

            %Sets Measurement Parameter
            obj.device.write(['MEAS{', obj.parameters.format, '}']);
            % Sets oscillation
            obj.device.write(['POWE ', num2str(obj.parameters.osc_level) ' V']);
            % Sets the sweep range start value. P444
            obj.device.write(['STAR ', num2str(obj.parameters.leftFq), 'HZ']);
            % Sets the sweep range stop value. P446
            obj.device.write(['STOP ', num2str(obj.parameters.rightFq), 'HZ']);
            % Sets the bandwidth. To set the bandwidth of each segment when creating the list sweep
            % table, also use this command. P274
            obj.device.write('BWFACT 2');
            %   Sets the transfer format for reading array data to the ASCII format (preset state). For details
            %  about transfer formats, refer to "Data Transfer Format" on page 78. (No query)
            obj.device.write('FORM4');
            % sets number of points of each sweep
            obj.device.write(['POIN ', num2str(obj.parameters.NOP)]);
            % Enable average measurement points
            obj.device.write('PAVER ON');
            % Points averaging factor
            obj.device.write(['PAVERFACT ', num2str(obj.parameters.p_aver)]);
        end

        function run(obj)
            %RUN includes loop to continuously query sweep data from device.
            %   Besides query data, visualization is also included.

            % frequencies of points of one sweep
            freqVector = linspace(obj.parameters.leftFq, obj.parameters.rightFq, obj.parameters.NOP);

            % sets real time plotting figure.
            obj.figureSetup();
            % sets STOP key handle
            keyHandle = uicontrol(...
                'Style', 'pushbutton', ...
                'String', 'Stop', ...
                'Position', [80, 5, 50, 20], ...
                'Callback', 'delete(gco)');

            % time counter
            timeZero = tic;
            % time vector records relative time when every sweep happens
            timeVector = [];

            % loop for continuously query
            while ishandle(keyHandle)
                [mag, phs] = obj.device.oneSweep();
                obj.plotData(freqVector, mag, phs);
                hold on;

                timeNow = toc(timeZero);
                timeVector = [timeVector timeNow];

                % save freq array (append mode), even program crushed, data will be saved.
                dlmwrite([obj.parameters.dir, obj.parameters.log, '_freq.csv'], [timeNow, freqVector], 'delimiter', ',', '-append');
                % save data1(real parts)
                dlmwrite([obj.parameters.dir, obj.parameters.log, '_real.csv'], [timeNow, transpose(mag)], 'delimiter', ',', '-append');
                % save data2(imagine parts)
                dlmwrite([obj.parameters.dir, obj.parameters.log, '_imag.csv'], [timeNow, transpose(phs)], 'delimiter', ',', '-append');

            end

            % loop ends when stop bottom is pushed

            % save original data figure.
            saveas(obj.figHandle, [obj.parameters.dir, obj.parameters.log, ' 2dFigure.png']);
            saveas(obj.figHandle, [obj.parameters.dir, obj.parameters.log, ' 2dFigure.fig']);

        end

        function figureSetup(obj)
            %figureSetup create axes and figures for real time plotting
            %   The axes and figures handle will become the properties of class measurement.
            obj.figHandle = figure('Position', [200, 200, 500, 500]);
            obj.data1Axis = subplot(1, 2, 1);
            xlabel('Frequency (Hz)');
            ylabel('Impedance Real Part (\Omega)');
            hold on;
            grid on;
            obj.data2Axis = subplot(1, 2, 2);
            xlabel('Frequency (Hz)');
            ylabel('Imaginary Part (\Omega)');
            hold on;
            grid on;
        end

        function plotData(obj, freq_vec, mag, phs)
            %plotData Plot the data on axes created before.
            plot(obj.data1Axis, freq_vec, mag);
            plot(obj.data2Axis, freq_vec, phs);

        end

    end

    methods (Static)
        par = parameterSetup();

    end

end
