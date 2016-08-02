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

classdef SyslogLoggerUnitTests < matlab.unittest.TestCase
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
                'mockFunction', @(varargin) fprintf(mockFd, varargin{:}) ...
            );

            testCase.logger = logging.SyslogLogger( ...
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
        function TestSyslogLoggerConstructor(testCase)
        %% Test constructor and creation of a ConsoleLogger
            testCase.verifyClass(testCase.logger, ?logging.SyslogLogger);
            testCase.verifyEqual(testCase.logger.facility, testCase.logger.DEFAULT_FACILITY);
        end

        %% Test getting syslog facilities from log levels
        function TestGetFacilityFromLogLevel_Aliases(testCase)
        %% Test that non-direct translations from logger LogLevel to syslog
        %% facility are handled properly
            aliases = [ ...
                {logging.LogLevel.TRACE, 'debug'},
                {logging.LogLevel.ERROR, 'err'},
                {logging.LogLevel.CRITICAL, 'crit'},
                {logging.LogLevel.EMERGENCY, 'emerg'},
            ];

            for i = 1:length(aliases)
                logLevel = aliases{i, 1};
                expectedFacility = aliases{i, 2};
                testCase.verifyEqual( ...
                    logging.SyslogLogger.getFacilityFromLogLevel(logLevel), expectedFacility ...
                );
            end
        end

        function TestGetFacilityFromLogLevel_DirectTranslation(testCase)
        %% Test that direct translations from logger LogLevel to syslog
        %% facility are handled properly
            logLevels = {'debug', 'info', 'notice', 'warning', 'alert'};

            for i = 1:length(logLevels)
                logLevel = logging.LogLevel.(upper(logLevels{i}));
                expectedFacility = logLevels{i};
                testCase.verifyEqual( ...
                    logging.SyslogLogger.getFacilityFromLogLevel(logLevel), expectedFacility ...
                );
            end
        end

        function TestGetFacilityFromLogLevel_Invalid(testCase)
        %% Test throws on an invalid level
            testCase.verifyError( ...
                @() testCase.logger.getFacilityFromLogLevel(-1), ...
                'logging:InvalidLogLevel' ...
            );
        end

        % testing the constructor -- deafult facility and not including timestamps
        % setting the facility
        % test logging basic message
        % test basic escaping of strings
    end
end