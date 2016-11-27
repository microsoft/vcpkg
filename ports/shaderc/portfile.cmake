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

set(SHADERC_GIT_URL "https://github.com/google/shaderc.git")
set(SHADERC_GIT_REF "2df47b51d83ad83cbc2e7f8ff2b56776293e8958")
if(NOT EXISTS "${DOWNLOADS}/shaderc.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${SHADERC_GIT_URL} ${DOWNLOADS}/shaderc.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()
if(NOT EXISTS "${SOURCE_PATH}/.git")
    message(STATUS "Adding worktree and patching")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${SOURCE_PATH} ${SHADERC_GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/shaderc.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
    vcpkg_execute_required_process(
        COMMAND ${GIT} apply ${CMAKE_CURRENT_LIST_DIR}/0001-Do-not-generate-build-version.inc.patch --ignore-whitespace --whitespace=fix
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME patch
    )
endif()

set(GLSLANG_GIT_URL "https://github.com/KhronosGroup/glslang.git")
set(GLSLANG_GIT_REF "1c573fbcfba6b3d631008b1babc838501ca925d3")
set(SPIRVTOOLS_GIT_URL "https://github.com/KhronosGroup/SPIRV-Tools.git")
set(SPIRVTOOLS_GIT_REF "f72189c249ba143c6a89a4cf1e7d53337b2ddd40")
set(SPIRVHEADERS_GIT_URL "https://github.com/KhronosGroup/SPIRV-Headers.git")
set(SPIRVHEADERS_GIT_REF "bd47a9abaefac00be692eae677daed1b977e625c")

if(NOT EXISTS "${DOWNLOADS}/SPIRV-Tools.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${SPIRVTOOLS_GIT_URL} ${DOWNLOADS}/SPIRV-Tools.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()
if(NOT EXISTS "${DOWNLOADS}/SPIRV-Headers.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${SPIRVHEADERS_GIT_URL} ${DOWNLOADS}/SPIRV-Headers.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()


file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/third_party/glslang)
if(NOT EXISTS "${SOURCE_PATH}/third_party/spirv-tools/.git")
    message(STATUS "Adding worktree and patching")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${SOURCE_PATH}/third_party/spirv-tools ${SPIRVTOOLS_GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/SPIRV-Tools.git
        LOGNAME worktree
    )
endif()
if(NOT EXISTS "${SOURCE_PATH}/third_party/spirv-tools/external/spirv-headers/.git")
    message(STATUS "Adding worktree and patching")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${SOURCE_PATH}/third_party/spirv-tools/external/spirv-headers ${SPIRVHEADERS_GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/SPIRV-Headers.git
        LOGNAME worktree
    )
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/build-version.inc DESTINATION ${SOURCE_PATH}/glslc/src)

#Note: glslang and spir tools doesn't export symbol and need to be build as static lib for cmake to work
set(VCPKG_LIBRARY_LINKAGE "static")
set(VCPKG_CRT_LINKAGE "static")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DSHADERC_SKIP_TESTS=true
    OPTIONS_DEBUG -DSUFFIX_D=true
    OPTIONS_RELEASE -DSUFFIX_D=false
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

#Safe to remove as libs are static
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
#Provided by another package (glslang)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)


# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/shaderc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/shaderc/LICENSE ${CURRENT_PACKAGES_DIR}/share/shaderc/copyright)
