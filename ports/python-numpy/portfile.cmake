include(vcpkg_common_functions)
set(PYTHON_EXECUTABLE ${CURRENT_INSTALLED_DIR}/python/python.exe)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO numpy/numpy
    REF v1.14.2
    SHA512 65b10462011e033669b700f0688df2e8630a097323fc7d72e71549fdfc2258546fe6f1317e0d51e1a0c9ab86451e0998ccbc7daa9af690652a96034571d5b76b 
    HEAD_REF master
)

message(STATUS "Installing...")
vcpkg_execute_required_process(
    COMMAND ${PYTHON_EXECUTABLE} -m pip install .
        -t ${CURRENT_PACKAGES_DIR}/python/Lib/site-packages
        --ignore-installed --compile
        --log ${CURRENT_BUILDTREES_DIR}/install-${TARGET_TRIPLET}-detailed.log
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME install-${TARGET_TRIPLET}
)
message(STATUS "Installing... done")

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
