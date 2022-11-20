vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PCRE2Project/pcre2
    REF pcre2-10.40
    SHA512 098c21d60ecb3bb8449173f50c9ab8e6018fafd5d55548be08b15df37f8e08bcd4f851d75758c4d22505db30a3444bb65783d83cd876c63fdf0de2850815ef93
    HEAD_REF master
    PATCHES
        pcre2-10.35_fix-uwp.patch
        no-static-suffix.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Emscripten" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "iOS")
    set(JIT OFF)
else()
    set(JIT ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_STATIC_LIBS=${BUILD_STATIC}
        -DPCRE2_BUILD_PCRE2_8=ON
        -DPCRE2_BUILD_PCRE2_16=ON
        -DPCRE2_BUILD_PCRE2_32=ON
        -DPCRE2_SUPPORT_JIT=${JIT}
        -DPCRE2_SUPPORT_UNICODE=ON
        -DPCRE2_BUILD_TESTS=OFF
        -DPCRE2_BUILD_PCRE2GREP=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(READ "${CURRENT_PACKAGES_DIR}/include/pcre2.h" PCRE2_H)
if(BUILD_STATIC)
    string(REPLACE "defined(PCRE2_STATIC)" "1" PCRE2_H "${PCRE2_H}")
else()
    string(REPLACE "defined(PCRE2_STATIC)" "0" PCRE2_H "${PCRE2_H}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/pcre2.h" "${PCRE2_H}")

vcpkg_fixup_pkgconfig()

# The cmake file provided by pcre2 has some problems, so don't use it for now.
#vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/cmake" "${CURRENT_PACKAGES_DIR}/debug/cmake")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/man")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(BUILD_STATIC)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
elseif(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/pcre2-config" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/..")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/pcre2-config")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/bin/pcre2-config" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/../..")
    endif()
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
