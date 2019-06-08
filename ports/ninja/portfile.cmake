SET(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ninja-build/ninja
    REF 2e64645749ff91eff2f999f03f55da360ae5913d # merge commit dyndep
    SHA512 c8299f85527be88208400633640ecfccd7d8a2b9cb3eefb98676d2cd99210ec8ffc643a02ad70eff75a0b57fd5c4c4a058fa47567d1e32d6381068c2397bef8e
    HEAD_REF master
    PATCHES
        version.patch #enables dyndep support (FORTRAN + C++20 MODULES)
)

vcpkg_find_acquire_program(PYTHON3)

message(STATUS "Copy files into triplet buildtree")
file(GLOB to_copy LIST_DIRECTORIES true "${SOURCE_PATH}/*")
set(TRIPLET_BUILDTREE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
file(COPY ${to_copy} DESTINATION ${TRIPLET_BUILDTREE})

message(STATUS "Configuring Ninja")
vcpkg_execute_required_process(
    COMMAND ${PYTHON3} configure.py #--bootstrap
    WORKING_DIRECTORY ${TRIPLET_BUILDTREE}
    LOGNAME config-${TARGET_TRIPLET}-rel
)

message(STATUS "Building Ninja")
vcpkg_find_acquire_program(NINJA)
vcpkg_execute_required_process(
    COMMAND ${NINJA}
    WORKING_DIRECTORY ${TRIPLET_BUILDTREE}
    LOGNAME build-${TARGET_TRIPLET}-rel
)

IF(VCPKG_CMAKE_SYSTEM_NAME MATCHES "Windows" OR NOT VCPKG_CMAKE_SYSTEM_NAME)
    set(CMAKE_EXECUTABLE_SUFFIX .exe)
endif()
file(INSTALL ${TRIPLET_BUILDTREE}/ninja${CMAKE_EXECUTABLE_SUFFIX} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ninja RENAME copyright)
