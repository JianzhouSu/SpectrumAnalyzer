classdef measurement

    properties
        parameters;
    end

    methods

        function obj = measurement()
            obj.parameters = parameterSetup();
        end

    end

end
