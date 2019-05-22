# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

FIND_PATH(UUID_INCLUDE_DIR uuid/uuid.h
          /usr/include
          /usr/include/linux
          /usr/local/include
          )

FIND_LIBRARY(UUID_LIBRARY NAMES uuid
             PATHS
             /usr/lib
             /usr/local/lib
             /usr/lib64
             /usr/local/lib64
             /lib/i386-linux-gnu
             /lib/x86_64-linux-gnu
             /usr/lib/x86_64-linux-gnu
             )

INCLUDE(FindPackageHandleStandardArgs)
IF (APPLE)
    FIND_PACKAGE_HANDLE_STANDARD_ARGS(UUID DEFAULT_MSG
                                      UUID_INCLUDE_DIR)
ELSE ()
    FIND_PACKAGE_HANDLE_STANDARD_ARGS(UUID DEFAULT_MSG
                                      UUID_LIBRARY UUID_INCLUDE_DIR)
ENDIF ()

MARK_AS_ADVANCED(UUID_INCLUDE_DIR UUID_LIBRARY)

IF (NOT UUID_LIBRARY)
    SET(UUID_FOUND FALSE)
    MESSAGE(FATAL_ERROR "UUID library not found.\nTry: 'sudo yum install libuuid uuid-devel' (or sudo apt-get install libuuid1 uuid-dev)")
ENDIF ()
