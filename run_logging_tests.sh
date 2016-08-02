#!/bin/bash

# Copyright 2016 Rob Capellini
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MATLAB=$(which matlab)
TEST_COMMAND='run_logging_tests'
HANDLE_ERROR='fprintf('"'"'%s\n'"'"', ME.message), exit(1)'

$MATLAB -nodisplay -r "try, $TEST_COMMAND, catch ME, $HANDLE_ERROR, end; exit(0)"
