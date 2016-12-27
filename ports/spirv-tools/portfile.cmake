# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
find_program(GIT git)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)

set(GIT_URL "https://github.com/KhronosGroup/SPIRV-Tools.git")
set(GIT_REF "f72189c249ba143c6a89a4cf1e7d53337b2ddd40")

if(NOT EXISTS "${DOWNLOADS}/spirv-tools.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/spirv-tools.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()

if(NOT EXISTS "${SOURCE_PATH}/.git")
    message(STATUS "Adding worktree and patching")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${SOURCE_PATH} ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/spirv-tools.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
endif()

set(SPIRVHEADERS_GIT_URL "https://github.com/KhronosGroup/SPIRV-Headers.git")
set(SPIRVHEADERS_GIT_REF "bd47a9abaefac00be692eae677daed1b977e625c")

if(NOT EXISTS "${DOWNLOADS}/SPIRV-Headers.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${SPIRVHEADERS_GIT_URL} ${DOWNLOADS}/SPIRV-Headers.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()

if(NOT EXISTS "${SOURCE_PATH}/external/spirv-headers/.git")
    message(STATUS "Adding worktree and patching")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${SOURCE_PATH}/external/spirv-headers ${SPIRVHEADERS_GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/SPIRV-Headers.git
        LOGNAME worktree
    )
endif()

set(VCPKG_LIBRARY_LINKAGE "static")

vcpkg_configure_cmake(
    SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src"
    # OPTIONS -DUSE_THIS_IN_ALL_BUILDS=1 -DUSE_THIS_TOO=2
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE ${EXES})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/spirv-tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/spirv-tools/LICENSE ${CURRENT_PACKAGES_DIR}/share/spirv-tools/copyright)
