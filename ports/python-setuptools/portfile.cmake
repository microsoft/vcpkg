include(vcpkg_common_functions)
set(PYTHON_EXECUTABLE ${CURRENT_INSTALLED_DIR}/python/python.exe)
set(PYTHON_DEBUG_EXECUTABLE ${CURRENT_INSTALLED_DIR}/debug/python/python_d.exe)

# install default pip
message(STATUS "Installing built-in pip wheel..")
vcpkg_execute_required_process(
    COMMAND ${PYTHON_DEBUG_EXECUTABLE} -m ensurepip --default-pip
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME install-pip-${TARGET_TRIPLET}-dbg
)
vcpkg_execute_required_process(
    COMMAND ${PYTHON_EXECUTABLE} -m ensurepip --default-pip
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME install-pip-${TARGET_TRIPLET}-rel
)
message(STATUS "Installing built-in pip wheel.. done")

# upgrade pip: need 9.0.2 to workaround https://github.com/pypa/pip/issues/373
message(STATUS "Upgrading pip..")
vcpkg_execute_required_process(
    COMMAND ${PYTHON_DEBUG_EXECUTABLE} -m pip install --upgrade pip
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME upgrade-pip-${TARGET_TRIPLET}-dbg
)
vcpkg_execute_required_process(
    COMMAND ${PYTHON_EXECUTABLE} -m pip install --upgrade pip
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME upgrade-pip-${TARGET_TRIPLET}-rel
)
message(STATUS "Upgrading pip.. done")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/python-pip-install.cmake
        ${CMAKE_CURRENT_LIST_DIR}/distutils-dbg.cfg.in
        ${CMAKE_CURRENT_LIST_DIR}/distutils-rel.cfg.in
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/python-setuptools)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
