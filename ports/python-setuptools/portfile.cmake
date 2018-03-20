include(vcpkg_common_functions)
set(PYTHON_EXECUTABLE ${CURRENT_INSTALLED_DIR}/python/python.exe)

vcpkg_execute_required_process(
    COMMAND ${PYTHON_EXECUTABLE} -m ensurepip --default-pip
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME install-pip-${TARGET_TRIPLET}
)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
