# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}

# This portfile implements a single depth clone from github. Always up to date!
include(FindGit)
if(NOT GIT_FOUND)
  message(FATAL_ERROR "FATAL: You need to install git to install this port")
endif()

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/boost.outcome")
  message(STATUS "Shallow cloning from https://github.com/ned14/boost.outcome.git ...")
  execute_process(COMMAND "${GIT_EXECUTABLE}" clone --depth 1 --recursive --jobs 4 https://github.com/ned14/boost.outcome.git
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}"
    OUTPUT_VARIABLE status
    RESULT_VARIABLE result
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
else()
  message(STATUS "Pulling updates from https://github.com/ned14/boost.outcome.git ...")
  execute_process(COMMAND "${GIT_EXECUTABLE}" pull
    WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/boost.outcome"
    OUTPUT_VARIABLE status
    RESULT_VARIABLE result
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
endif()
if(NOT result EQUAL 0)
  message(FATAL_ERROR "FATAL: git failed with error '${result}'. Is your git new enough (>= 2.11)?")
endif()

message(STATUS "Updating submodules ...")
execute_process(COMMAND "${GIT_EXECUTABLE}" submodule update --init --recursive
  WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/boost.outcome"
  OUTPUT_VARIABLE status
  RESULT_VARIABLE result
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT result EQUAL 0)
  message(FATAL_ERROR "FATAL: git failed with error '${result}'")
endif()

message(STATUS "Installing ...")
file(INSTALL ${CURRENT_BUILDTREES_DIR}/boost.outcome/include/boost DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# boost license does not exist in source folder.
include(vcpkg_common_functions)
vcpkg_download_distfile(LICENSE
	URLS http://www.boost.org/LICENSE_1_0.txt
	FILENAME "boost-outcome-copyright"
	SHA512 d6078467835dba8932314c1c1e945569a64b065474d7aced27c9a7acc391d52e9f234138ed9f1aa9cd576f25f12f557e0b733c14891d42c16ecdc4a7bd4d60b8
)
file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/boost-outcome/copyright)