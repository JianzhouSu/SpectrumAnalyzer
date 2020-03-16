classdef measurement < handle

    properties
        parameters;
        device;
        figHandle;
    end

    methods

        function obj = measurement()
            obj.parameters = obj.parameterSetup();
            obj.device = A4294A(obj.parameters.comPort);
            obj.init();
            obj.run();

            % END OF CODE
            disp("END OF CODE");
        end

        function init(obj)

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
            freqVector = linspace(obj.parameters.leftFq, obj.parameters.rightFq, obj.parameters.NOP);

            keyHandle = uicontrol(...
                'Style', 'pushbutton', ...
                'String', 'Stop', ...
                'Position', [80, 5, 50, 20], ...
                'Callback', 'delete(gco)');
            timeZero = tic;
            timeVector = [];

            while ishandle(keyHandle)
                [mag, phs] = obj.device.oneSweep();
                obj.figHandle = obj.plot_mag_phs(freqVector, mag, phs);
                hold on;

                timeNow = toc(timeZero);
                timeVector = [timeVector timeNow];

                % save freq array
                dlmwrite([obj.parameters.dir, obj.parameters.log, '_freq.csv'], [timeNow, freqVector], 'delimiter', ',', '-append'); % append mode
                % save mag parts
                dlmwrite([obj.parameters.dir, obj.parameters.log, '_real.csv'], [timeNow, transpose(mag)], 'delimiter', ',', '-append');
                % save phs parts
                dlmwrite([obj.parameters.dir, obj.parameters.log, '_imag.csv'], [timeNow, transpose(phs)], 'delimiter', ',', '-append');
                % analyze data
                % [resf, fwhm, Q] = obj.analyze(mag, phs, freqVector);
                %Plot Analysis
                % obj.plotana(timeVector, resf, fwhm, Q);
                %Save analysis
                % dlmwrite([obj.parameters.dir, obj.parameters.log, '_analysis.csv'], [timeNow, resf, fwhm, Q], 'delimiter', ',', '-append');
            end
            saveas(obj.figHandle,[obj.parameters.dir, obj.parameters.log, ' 2dFigure.png']);
            saveas(obj.figHandle,[obj.parameters.dir, obj.parameters.log, ' 2dFigure.fig']);
            % fprintf(ia, "SING");

            % disp(wait_4294a(ia, 'Sweep Finished: '));

        end

    end

    methods (Static)
        par = parameterSetup();

        function figureOut = plot_mag_phs(freq_vec, mag, phs)
            %     f1 = figure('Position', [200, 200, 500, 500]);
            figureOut = figure();
            subplot(1, 2, 1);
            plot(freq_vec, mag);
            xlabel('Frequency (Hz)');
            ylabel('Impedance Real Part (\Omega)');
            hold on;
            grid on;
            subplot(1, 2, 2);
            plot(freq_vec, phs);
            xlabel('Frequency (Hz)');
            ylabel('Imaginary Part (\Omega)');
            hold on;
            grid on;

        end

        % function [resf, fwhm, Q] = analyze(real, img, freq_vec)

        %     % Find RF
        %     RFindex = find(real == max(real));
        %     resf = freq_vec(RFindex);

        %     %Find FWHM Bandwidth
        %     halfMax = (min(real) + max(real)) / 2;
        %     % Find where the data first drops below half the max.
        %     index1 = find(real >= halfMax, 1, 'first');
        %     % Find where the data last rises above half the max.
        %     index2 = find(real >= halfMax, 1, 'last');
        %     fwhm = freq_vec(index2) - freq_vec(index1);
        %     % Find Q
        %     Q = resf / fwhm;

        % end

        % function plotana(time_vec, resf, fwhm, Q)
        %     figure(2);
        %     subplot(3, 1, 1);
        %     plot(time_vec, resf);
        %     xlabel('Time(s)');
        %     ylabel('Resonant Frequency(Hz)');
        %     grid on;
        %     subplot(3, 1, 2);
        %     plot(time_vec, fwhm);
        %     xlabel('Time(s)');
        %     ylabel('Bandwidth(Hertz)');
        %     grid on;
        %     subplot(3, 1, 3)
        %     plot(time_vec, Q);
        %     xlabel('Time(s)');
        %     ylabel('Quality Factor');
        %     grid on
        %     legend;
        %     drawnow;
        % end

    end

end
