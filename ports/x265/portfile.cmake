vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO videolan/x265
    REF 07295ba7ab551bb9c1580fdaee3200f1b45711b7 #v3.4
    SHA512 21a4ef8733a9011eec8b336106c835fbe04689e3a1b820acb11205e35d2baba8c786d9d8cf5f395e78277f921857e4eb8622cf2ef3597bce952d374f7fe9ec29
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
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
endif()
vcpkg_copy_tools(TOOL_NAMES x265 AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR VCPKG_TARGET_IS_LINUX)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND (NOT VCPKG_TARGET_IS_MINGW))
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/x265.pc" "-lx265" "-lx265-static")
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/x265.pc" "-lx265" "-lx265-static")
        endif()
    endif()
endif()

# maybe create vcpkg_regex_replace_string?

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(READ ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/x265.pc _contents)
    string(REGEX REPLACE "-l(std)?c\\+\\+" "" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/x265.pc "${_contents}")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/x265.pc _contents)
    string(REGEX REPLACE "-l(std)?c\\+\\+" "" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/x265.pc "${_contents}")
endif()

if(VCPKG_TARGET_IS_MINGW AND ENABLE_SHARED)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/libx265.a)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/libx265.a)
    endif()
endif()

if(UNIX)
    foreach(FILE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/x265.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/x265.pc")
        if(EXISTS "${FILE}")
            file(READ "${FILE}" _contents)
            string(REPLACE " -lstdc++" "" _contents "${_contents}")
            string(REPLACE " -lc++" "" _contents "${_contents}")
            string(REPLACE " -lgcc_s" "" _contents "${_contents}")
            string(REPLACE " -lgcc" "" _contents "${_contents}")
            string(REPLACE " -lrt" "" _contents "${_contents}")
            file(WRITE "${FILE}" "${_contents}")
        endif()
    endforeach()
    vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES numa)
else()
    vcpkg_fixup_pkgconfig()
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
