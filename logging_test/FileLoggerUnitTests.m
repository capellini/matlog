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

classdef FileLoggerUnitTests < matlab.unittest.TestCase
    properties
        TESTLOG = 'testlog.out';
    end

    properties
        logger
    end

    methods (TestMethodSetup)
        function createFixture(testCase)
            assert(~exist(testCase.TESTLOG, 'file'));
            testCase.logger = logging.FileLogger(testCase.TESTLOG);
        end
    end

    methods (TestMethodTeardown)
        function removeTestFile(testCase)
            if exist(testCase.TESTLOG, 'file')
                delete(testCase.TESTLOG);
            end
        end
    end

    methods (Test)
        function TestFileLoggerConstructor(testCase)
        %% Test constructor and creation of a FileLogger
            testCase.verifyClass(testCase.logger, ?logging.FileLogger);
            testCase.verifyEqual(testCase.logger.logFile, testCase.TESTLOG);
        end

        function TestDirectoryCreated(testCase)
        %% Creates a directory if one is specified and it does not already exist
            testCase.assumeTrue(~exist('loggingtestdirectory', 'dir'));

            logFile = fullfile('loggingtestdirectory', testCase.TESTLOG);
            testCase.addTeardown(@() rmdir('loggingtestdirectory', 's'));
            logging.FileLogger(logFile);

            testCase.verifyTrue(exist('loggingtestdirectory', 'dir') > 0);
        end

        function TestNoFileCreatedWhenNoLogEntries(testCase)
        %% Does not create a file unless logs are entered into the file
            testCase.verifyEqual(exist(testCase.TESTLOG, 'file'), 0)
        end

        function TestLoggingCreatesFileAndLogsEntryToFile(testCase)
        %% Log entries result in the file being created and the log being
        %% entered
            testCase.assumeTrue(~exist(testCase.TESTLOG, 'file'));

            testCase.logger.emergency('Log this');

            TestHelper.verifyLogEntry(testCase, testCase.TESTLOG, 'Log this');
        end
    end
end