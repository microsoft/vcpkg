include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO multicoreware/x265_git
    REF 3.2
    SHA512 1c6dc000dd1ccc1846cd1d29e8f4ba3bfaa2c0579ab02be3b6a85f0aa3612a717850db5e55ef7a5ac78aaa730e1d20c34b03e40260a927edec72bd3146f12ff5
    HEAD_REF master
    PATCHES
        disable-install-pdb.patch
)

set(ENABLE_ASSEMBLY OFF)
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    set(ENV{PATH} "$ENV{PATH};${NASM_EXE_PATH}")
    set(ENABLE_ASSEMBLY ON)
endif ()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/source
    PREFER_NINJA
    OPTIONS
        -DENABLE_ASSEMBLY=${ENABLE_ASSEMBLY}
        -DENABLE_SHARED=${ENABLE_SHARED}
    OPTIONS_DEBUG
        -DENABLE_CLI=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# remove duplicated include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/x265)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/x265 ${CURRENT_PACKAGES_DIR}/tools/x265/x265)
elseif(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/x265.exe ${CURRENT_PACKAGES_DIR}/tools/x265/x265.exe)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR VCPKG_TARGET_IS_LINUX)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/x265)

if(WIN32 AND (NOT MINGW))
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/x265.pc" "-lx265" "-lx265-static")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/x265.pc" "-lx265" "-lx265-static")
    endif()
endif()
if(UNIX)
    vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES numa)
else()
    vcpkg_fixup_pkgconfig()
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/x265)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/x265/COPYING ${CURRENT_PACKAGES_DIR}/share/x265/copyright)
