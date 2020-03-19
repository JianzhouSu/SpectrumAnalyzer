classdef A4294A < handle
    % A4294A class for network analyzer Agilent A4294A
    %   property: SERIALPORT serial class of device. Treated as device.

    properties
        % all properties are public, should be improved in future.
        serialPort; % serial port class
    end

    methods

        function obj = A4294A(comPort)
            % A4294A Network analyzer class constructor

            % reset all instruments connected to matlab.
            % Might create some problem when multiple devices connected.
            % instrreset;

            % According to prologix, baud rate doesn't matters.
            % Sets terminator of message is LF(ascii 10)
            obj.serialPort = serial(comPort, 'BaudRate', 115200, 'Terminator', 'LF');

            % Communication timeout setup (unit: seconds)
            obj.serialPort.Timeout = 15;

            % Input buffer size: make it large enough to save one sweep.
            obj.serialPort.InputBufferSize = 10 * 20001;

            % Initialize device
            obj.init();
        end

        function delete(obj)
            % Destructor
            %   function processed when instance is cleared.

            % close serial port
            fclose(obj.serialPort);
        end

        function write(obj, command)
            % WRITE Write command on serial port.
            %   input: command should be strings
            fprintf(obj.serialPort, command);
        end

        function output = read(obj)
            % READ Read the Ascii string from serial port.
            %   Return strings from serial port.
            output = fgets(obj.serialPort);
        end

        function stats = wait(obj)
            % todo: haven't done yet.
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
            % GetID query ID information from device.
            %   used as a function to test communication between device and PC.
            obj.write('*IDN?');
            idn = obj.read();
            disp(['Serial ready:', idn]);
            output = idn;
        end

        function init(obj)
            %init - setup analyzer
            % Initialize prologix and Agilent 4924A

            fopen(obj.serialPort);
            % prologix (serial to gpib converter) settings
            obj.write('++mode 1');
            obj.write('++addr 17');
            obj.write('++auto 1');
            obj.write('++eoi 1');
            obj.write('++eos 2');
            obj.write('read_tmo_ms 3000');
            % Test serial communication
            obj.getId();
            % Wait when device is occupied, need to be improved.
            obj.wait();

        end

        function [data1, data2] = oneSweep(obj)
            %oneSweep - Return one sweep data
            %
            % Syntax: data1, data2 = oneSweep(obj)
            %
            % Query device for one sweep data. When using data format 'RX', data1 should be real part and data2 is imagine part.
            % Base on code for 4294A by Vineeth.

            obj.write('HOLD');
            obj.write('TRGS INT');
            obj.write('SING');
            % todo: need to be improved, 10 seconds delay might be too much.
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
