include(vcpkg_common_functions)
set(PYTHON_EXECUTABLE ${CURRENT_INSTALLED_DIR}/python/python.exe)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cython/cython
    REF 0.28.1
    SHA512 3346ebe01049ff6628f74ee1904d440680ccc7fc09c51afd26d6e05264318678c9fb64da4d98703d3e687662e98125e0b182d01cb9276cbb4fcb014ecb35be63 
    HEAD_REF master
)

message(STATUS "Installing...")
# use -t will not install tools under /Scripts
vcpkg_execute_required_process(
    COMMAND ${PYTHON_EXECUTABLE} -m pip install . -t ${CURRENT_PACKAGES_DIR}/python/Lib/site-packages --ignore-installed --compile
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME install-${TARGET_TRIPLET}
)
message(STATUS "Installing... done")

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
