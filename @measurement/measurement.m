classdef measurement < handle

    properties
        parameters;
        device;
    end

    methods

        function obj = measurement()
            obj.parameters = obj.parameterSetup();
            obj.device = A4294A(par.comPort);
        end

    end

end
