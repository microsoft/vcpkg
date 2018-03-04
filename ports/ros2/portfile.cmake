include(vcpkg_common_functions)

vcpkg_acquire_python(PYTHON3 PACKAGES vcstool EmPy pyparsing pyyaml)
file(DOWNLOAD "https://raw.githubusercontent.com/ros2/ros2/release-latest/ros2.repos" ${CURRENT_BUILDTREES_DIR}/src/ros2.repos)

# Setting up environments
find_program(GIT NAMES git git.cmd)
get_filename_component(GIT_EXE_PATH ${GIT} DIRECTORY)
get_filename_component(CMAKE_EXE_PATH ${CMAKE_COMMAND} DIRECTORY)
get_filename_component(PYTHON_EXE_PATH ${PYTHON3_EXECUTABLE} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${GIT_EXE_PATH};${CMAKE_EXE_PATH};${PYTHON_EXE_PATH}")

# Add path to embedded python
if(NOT EXISTS ${PYTHON_EXE_PATH}/ros2.pth)
    file(WRITE ${PYTHON_EXE_PATH}/ros2.pth "${CURRENT_PACKAGES_DIR}/Lib/site-packages")
endif()

message(STATUS "Fetching sources...")
vcpkg_execute_required_process(
    COMMAND ${PYTHON3_EXECUTABLE} -m vcstool.commands.vcs import --input src/ros2.repos src
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME python-install-pip-${TARGET_TRIPLET}
)
message(STATUS "Fetching sources... done")

message(STATUS "Building...")
vcpkg_execute_required_process(
    COMMAND ${PYTHON3_EXECUTABLE} ${CURRENT_BUILDTREES_DIR}/src/ament/ament_tools/scripts/ament.py build
        --build-space ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        --install-space ${CURRENT_PACKAGES_DIR}
        --cmake-args
            -D
        --
        --use-ninja
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME install-${TARGET_TRIPLET}
)
message(STATUS "Building... done")

file(REMOVE ${PYTHON_EXE_PATH}/ros2.pth)
