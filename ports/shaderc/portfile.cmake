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

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/third_party/glslang)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists_spirv.txt DESTINATION ${SOURCE_PATH}/third_party/spirv-tools)
file(RENAME ${SOURCE_PATH}/third_party/spirv-tools/CMakeLists_spirv.txt ${SOURCE_PATH}/third_party/spirv-tools/CMakeLists.txt)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/build-version.inc DESTINATION ${SOURCE_PATH}/glslc/src)

#Note: glslang and spir tools doesn't export symbol and need to be build as static lib for cmake to work
set(VCPKG_LIBRARY_LINKAGE "static")
set(OPTIONS)
if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS -DSHADERC_ENABLE_SHARED_CRT=ON)
endif()

# shaderc uses python to manipulate copyright information
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)
set(ENV{PATH} "${PYTHON3_EXE_PATH};$ENV{PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DSHADERC_SKIP_TESTS=true ${OPTIONS}
    OPTIONS_DEBUG -DSUFFIX_D=true
    OPTIONS_RELEASE -DSUFFIX_D=false
)

vcpkg_install_cmake()

file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

#Safe to remove as libs are static
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)


file(WRITE ${CURRENT_PACKAGES_DIR}/include/shaderc.txt)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/shaderc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/shaderc/LICENSE ${CURRENT_PACKAGES_DIR}/share/shaderc/copyright)
