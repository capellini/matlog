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

classdef ConsoleLoggerUnitTests < matlab.unittest.TestCase
    properties (Constant)
        MOCKFILENAME = 'test.out';
    end

    properties (Access = protected)
        logger
        fprintfMock
    end

    methods (TestMethodSetup)
        function createFixture(testCase)
            assert(~exist(testCase.MOCKFILENAME, 'file'));

            % mock out fprintf console logging
            mockFd = fopen(testCase.MOCKFILENAME, 'w');

            % first argument to fprintf is the console file descriptor
            % (i.e. 1), so ignore that field and log to our mock file instead
            testCase.fprintfMock = struct( ...
                'mockFileName', testCase.MOCKFILENAME, 'mockFd', mockFd, ...
                'mockFunction', @(varargin) fprintf(mockFd, varargin{2:end}) ...
            );

            testCase.logger = logging.ConsoleLogger( ...
                struct('fprintf', testCase.fprintfMock.mockFunction) ...
            );
        end
    end

    methods (TestMethodTeardown)
        function removeLogFile(testCase)
            fclose(testCase.fprintfMock.mockFd);
            delete(testCase.fprintfMock.mockFileName);
        end
    end

    methods (Test)
        function TestConsoleLoggerConstructor(testCase)
        %% Test constructor and creation of a ConsoleLogger
            testCase.verifyClass(testCase.logger, ?logging.ConsoleLogger);
            testCase.verifyEqual(testCase.logger.CONSOLE, 1);
        end

        function TestLogging(testCase)
            testCase.logger.emergency('log this');
            TestHelper.verifyLogEntry( ...
                testCase, testCase.fprintfMock.mockFileName, 'log this' ...
            );
        end
    end
end