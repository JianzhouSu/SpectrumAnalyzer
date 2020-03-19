classdef sweep < handle
    %SWEEP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vFrequency;     % frequency vector
        vValues;        % values vector
        time;           % time when sweep happen
        resonateFreq;   % resonate frequency of current data
        bandwidth;      % bandwidth of spectrum
        qFactor;        % quality factor
    end
    
    methods
        function obj = sweep(time,vFreq,vVal)
            %SWEEP Construct an instance of this class
            %   Detailed explanation goes here
            obj.time = time;
            obj.vFrequency = vFreq;
            obj.vValues = vVal;
        end
        
        function baselineCorrect(obj,order)
            %baselineCorrect Summary of this method goes here
            %   Detailed explanation goes here
            
            % default polyfit order
            if nargin <1
                order = 2;
            end
            % exponential polyfit to remove peak
            coefficients = polyfit(obj.vFrequency, log(obj.vValues), order);
            % exponential polyval to create baseline
            baseline = exp(polyval(coefficients, obj.vFrequency));
            % baseline correction
            obj.vValues = obj.vValues-baseline;
        end
        
        function axisHandleOut = plot2d(obj,axisHandle)
            %plot2d Summary of this method goes here
            %   Detailed explanation goes here
            if nargin <1
                % if no axis inputted, create a new axes()
                axisHandleOut = axes();
            else
                % return the axis plotted on
                axisHandleOut = axisHandle;
            end
            % plot function here (todo: any title and xy label)
            plot(axisHandleOut, obj.vFrequency, obj.vValues);
            hold on;
        end
        
        function bandwidth = getBandwidth(obj)
            % getBandwidth Summary of this method goes here
            %   Detailed explanation goes here           

            if isempty(obj.bandwidth)
                obj.startAnalyze()
            end
            bandwidth = obj.bandwidth;
        end
        
        function rf = getResonateFreq(obj)
            % getBandwidth Summary of this method goes here
            %   Detailed explanation goes here           

            if isempty(obj.resonateFreq)
                obj.startAnalyze()
            end
            rf = obj.resonateFreq;
        end
        
        function qf = getQFactor(obj)
            % getBandwidth Summary of this method goes here
            %   Detailed explanation goes here           

            if isempty(obj.qFactor)
                obj.startAnalyze()
            end
            qf = obj.qFactor;
        end
                        
        function startAnalyze(obj,interpolateNum)
            % getBandwidth calculate the resonate frequency, bandwidth and
            % quality factor
            if nargin < 2
                % default interpolating number
                interpolateNum = 10;
            end
            % interpolate frequency vector
            freqInterval = (obj.vFrequency(2) - obj.vFrequency(1)) / interpolateNum;
            interpFreq = obj.vFrequency(1):freqInterval:obj.vFrequency(end);
            % interpolate values vector
            interpValues = interp1(obj.vFrequency, obj.vValues, interpFreq);
            % find maximum point
            [maxRealPart, maxInterpIdx] = max(interpValues);
            % get peak values' frequency
            obj.resonateFreq = interpFreq(maxInterpIdx);
            % define threshold as half point
            threshold = maxRealPart / 2;
            
            % find left point (todo: optimize this function)
            leftIdx = maxInterpIdx;
            while (leftIdx > 1) && (interpValues(leftIdx) > threshold)
                leftIdx = leftIdx - 1;
            end
            leftFreq = interpFreq(leftIdx);
            % find right point (todo: optimize this function)
            rightIdx = maxInterpIdx;
            while (rightIdx < size(interpValues, 2)) && (interpValues(rightIdx) > threshold)
                rightIdx = rightIdx + 1;
            end
            rightFreq = interpFreq(rightIdx);
            
            % calculate bandwidth
            obj.bandwidth = rightFreq - leftFreq;
            
            % calculate quality factor
            obj.qFactor = obj.resonateFreq/obj.bandwidth;
        end
        
        function smoothValues(obj)
            obj.vValues = smooth(obj.vValues, 0.2, 'loess')';
        end
    end
end

