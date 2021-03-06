% Copyright 2016 Rob Capellini
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.

classdef NullLogger < logging.Logger
%% NULLLOGGER - Null pattern logger.  Used for testing.
    properties
        log
    end

    methods
        function obj = NullLogger(varargin)
            obj@logging.Logger(varargin{:});
            obj.log = {};
        end

        function clearLog(obj)
            obj.log = {};
        end
    end

    methods (Access = protected)
        function logMessage(obj, message)
            obj.log{length(obj.log) + 1} = message;
        end
    end
end