vcpkg_find_acquire_program(PYTHON3)

message(STATUS "Installing built-in pip wheel..")
if(NOT EXISTS ${PYTHON_PREFIX}/Scripts/pip)
    vcpkg_from_github(
        OUT_SOURCE_PATH PYFILE_PATH
        REPO pypa/get-pip
        REF 1fe530e9e3d800be94e04f6428460fc4fb94f5a9
        SHA512 e1b03b89418572c1e52e6aa9740333877af7145b080d70d1ffe63bd94871f61ea057457ae589fa55d172fd6e0511e0de021b02c693abd17289310e36e6d8a618
        HEAD_REF master
    )
endif()

vcpkg_execute_required_process(
    COMMAND ${Python3_EXECUTABLE} ${PYFILE_PATH}/get-pip.py
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME install-pip-${TARGET_TRIPLET}-rel
)
message(STATUS "Installing built-in pip wheel.. done")

message(STATUS "Upgrading pip..")
vcpkg_execute_required_process(
    COMMAND ${Python3_EXECUTABLE} -m pip install -U --force pip setuptools wheel pep517
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME upgrade-pip-${TARGET_TRIPLET}-rel
)
message(STATUS "Upgrading pip.. done")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/distutils-rel.cfg.in DESTINATION ${SCRIPTS}/templates)#${VCPKG_ROOT_DIR}

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
