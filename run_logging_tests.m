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

function run_logging_tests()
    import matlab.unittest.TestSuite;
    import matlab.unittest.TestRunner;

    lastPath = addpath(fullfile(pwd, 'logging_test'));
    c1 = onCleanup(@() restorePath(lastPath));

    testFiles = {'LoggerUnitTests.m', 'ConsoleLoggerUnitTests.m', ...
                 'FileLoggerUnitTests.m', 'SyslogLoggerUnitTests.m', ...
                 'ConfigureLoggingUnitTests.m'};

    for i = 1:length(testFiles)
        testsuite = TestSuite.fromFile(testFiles{i});
        runner = TestRunner.withTextOutput;
        result = runner.run(testsuite);

        if any([result.Failed])
            throw(MException( ...
                'logging:FailedUnitTest', sprintf(['%d tests failed.'], sum([result.Failed])) ...
            ));
        end
    end
end

function restorePath(lastPath)
    path(lastPath);
end