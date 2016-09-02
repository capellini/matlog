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

classdef TestHelper < handle
    properties (Constant)
        LOG_LEVELS = { ...
            'ALL', 'TRACE', 'DEBUG', 'INFO', 'NOTICE', ...
            'WARNING', 'ERROR', 'CRITICAL', 'ALERT', 'EMERGENCY' ...
        };
    end

    methods (Static)
        function verifyStructsAreEqual(testCase, struct1, struct2)
            testCase.verifyTrue(isstruct(struct1));
            testCase.verifyTrue(isstruct(struct2));

            testCase.verifyEqual(properties(struct1), properties(struct2));

            props = properties(struct1);
            for i = 1:length(props)
                testCase.verifyEqual(struct1.(props(i)), struct2.(props(i)));
            end
        end

        function verifyLogEntry(testCase, logFile, logString, varargin)
            if nargin > 3
                options = varargin;
            else
                options = {};
            end

            fileData = TestHelper.getFileData(testCase, logFile, options{:});
            testCase.verifySubstring(fileData, logString);
        end

        function verifyLogIsEmpty(testCase, logFile)
        % fgetl returns -1 when it fails to read a line, so if it returns -1
        % on the first request, then we know the file is empty
            fd = fopen(logFile);
            fgetLReturnValue = fgetl(fd);
            fclose(fd);

            testCase.verifyEqual(fgetLReturnValue, -1);
        end

        function verifyNumLinesInLog(testCase, logFile, numLines)
            fd = fopen(logFile);
            actualLines = 0;
            tline = fgets(fd);
            while tline ~= -1
                actualLines = actualLines + 1;
                tline = fgets(fd);
            end
            fclose(fd);

            testCase.verifyEqual(actualLines, numLines);
        end

        function fileData = getFileData(testCase, logFile, varargin)
            if nargin > 2
                options = struct(varargin{:});
            else
                options = struct();
            end

            if isfield(options, 'lineNum')
                lineNum = options.lineNum;
            else
                lineNum = 1;
            end

            fd = fopen(logFile);
            currentLine = 0;
            while currentLine < lineNum
                fileData = fgetl(fd);
                currentLine = currentLine + 1;
            end
            fclose(fd);
        end
    end
end