classdef A4294A < handle

    properties
        serialPort; % serial port class

    end

    methods

        function obj = A4294A(comPort)
            % A4294A Network analyzer class

            % reset all instruments connected to matlab.
            instrreset;

            % According to prologix, baud rate doesn't matters.
            % Sets terminator of message is LF(ascii 10)
            obj.serialPort = serial(comPort, 'BaudRate', 115200, 'Terminator', 'LF');

            % Communication timeout setup (unit: seconds)
            obj.serialPort.Timeout = 5;
            % Input buffer size setup
            obj.serialPort.InputBufferSize = 10 * 20001;
            % Initialize
            obj.init();
        end

        function write(obj, command)
            fprintf(obj.serialPort, command);
        end

        function output = read(obj)
            output = fgets(obj.serialPort);
        end

        function stats = wait(obj)
            pause(0.1);
%             obj.write("*OPC?");
% 
%             if isempty(obj.read())
                stats = 'Ready';
%             else
%                 stats = 'Busy';
%             end

        end

        function output = getId(obj)
            obj.write('*IDN?');
            idn = obj.read();
            disp(['Serial ready:', idn]);
            output = idn;
        end

        function init(obj)
            %init - setup analyzer
            % Initialize prologix and Agilent 4924A

            fopen(obj.serialPort);
            obj.write('++mode 1');
            obj.write('++addr 17');
            obj.write('++auto 1');
            obj.write('++eoi 1');
            obj.write('++eos 2');
            obj.write('read_tmo_ms 3000');
            obj.getId();

            obj.wait();

        end

        function [data1, data2] = oneSweep(obj)
            %myFun - Description
            %
            % Syntax: data1, data2 = oneSweep(obj)
            %
            % Long description
            obj.write('HOLD');
            obj.write('TRGS INT');
            obj.write('SING');
            pause(10);
            disp(obj.wait());
            pause(0.1);
            obj.write('TRAC A');
            %     obj.write('FMT LOGY');
            obj.write('AUTO');
            obj.write('OUTPDTRC?');
            data1 = str2double(split(obj.read(), ','));
            data1 = data1(1:2:end);
            obj.write('TRAC B');
            %     obj.write('FMT LINY');
            obj.write('AUTO');
            obj.write('OUTPDTRC?');
            data2 = str2double(split(obj.read(), ','));
            data2 = data2(1:2:end);
            disp(obj.wait());
            disp('Data acquisition finished');
        end

    end

end
