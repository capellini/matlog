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

classdef LogLevel < double
    enumeration
        INFO      (2)   % info must be first to be the default level
        ALL       (0)
        TRACE     (0)
        DEBUG     (1)
        NOTICE    (3)
        WARNING   (4)
        ERROR     (5)
        CRITICAL  (6)
        ALERT     (7)
        EMERGENCY (8)
    end

    methods (Static)
        function level = getLogLevelFromString(level)
            levelUppercase = upper(level);

            try
                level = logging.LogLevel.(levelUppercase);
            catch ME
                switch ME.identifier
                    case 'MATLAB:subscripting:classHasNoPropertyOrMethod'
                      logging.LogLevel.throwInvalidLevel();
                  otherwise
                    rethrow(ME)
                end
            end
        end

        function throwInvalidLevel()
            throw(MException('logging:InvalidLogLevel', 'Unrecognized error level.'));
        end
    end
end
