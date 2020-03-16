classdef measurement < handle

    properties
        parameters;
        device;
    end

    methods

        function obj = measurement()
            obj.parameters = obj.parameterSetup();
            obj.device = A4294A(obj.parameters.comPort);
        end

    end

end
