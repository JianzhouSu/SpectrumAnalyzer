classdef measurement < handle

    properties
        parameters;
    end

    methods

        function obj = measurement()
            obj.parameters = obj.parameterSetup();
        end

    end

end
