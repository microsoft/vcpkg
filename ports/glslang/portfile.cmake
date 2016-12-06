# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/KhronosGroup/glslang.git")
set(GIT_REF "1c573fbcfba6b3d631008b1babc838501ca925d3")

if(NOT EXISTS "${DOWNLOADS}/glslang.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/glslang.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree and patching")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/glslang.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
endif()

set(VCPKG_LIBRARY_LINKAGE "static")

vcpkg_configure_cmake(
    SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/src"
)

vcpkg_install_cmake()

file(COPY "${CURRENT_BUILDTREES_DIR}/src/glslang/Public" DESTINATION ${CURRENT_PACKAGES_DIR}/include/glslang)
file(COPY "${CURRENT_BUILDTREES_DIR}/src/glslang/Include" DESTINATION ${CURRENT_PACKAGES_DIR}/include/glslang)
file(COPY "${CURRENT_BUILDTREES_DIR}/src/glslang/MachineIndependent/Versions.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include/glslang/MachineIndependent)
file(COPY "${CURRENT_BUILDTREES_DIR}/src/SPIRV/Logger.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include/SPIRV)
file(COPY "${CURRENT_BUILDTREES_DIR}/src/SPIRV/spirv.hpp" DESTINATION ${CURRENT_PACKAGES_DIR}/include/SPIRV)
file(COPY "${CURRENT_BUILDTREES_DIR}/src/SPIRV/GlslangToSpv.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include/SPIRV)
file(COPY "${CURRENT_PACKAGES_DIR}/bin/glslangValidator.exe" DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/glslangValidator.exe")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/glslangValidator.exe")
file(COPY "${CURRENT_PACKAGES_DIR}/bin/spirv-remap.exe" DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/spirv-remap.exe")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/spirv-remap.exe")

file(GLOB BIN_DIR "${CURRENT_PACKAGES_DIR}/bin/*")
list(LENGTH BIN_DIR BIN_DIR_SIZE)
if(${BIN_DIR_SIZE} EQUAL 0)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
endif()
file(GLOB DEBUG_BIN_DIR "${CURRENT_PACKAGES_DIR}/debug/bin/*")
list(LENGTH DEBUG_BIN_DIR DEBUG_BIN_DIR_SIZE)
if(${DEBUG_BIN_DIR_SIZE} EQUAL 0)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/glslang)
