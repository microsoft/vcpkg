vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BelledonneCommunications/bcg729
    REF 1.1.1
    SHA512 e8cc4b7486a9a29fb729ab9fd9e3c4a2155573f38cec16f5a53db3b416fc1119ea5f5a61243a8d37cb0b64580c5df1b632ff165dc7ff47421fa567dafffaacd8
    HEAD_REF master
    PATCHES
        disable-alt-packaging.patch
)

# Already removed upstream: https://github.com/BelledonneCommunications/bcg729/pull/19
file(REMOVE "${SOURCE_PATH}/include/MSVC/stdint.h")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DENABLE_SHARED=${ENABLE_SHARED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME Bcg729)
file(GLOB cmake_files "${CURRENT_PACKAGES_DIR}/share/Bcg729/cmake/*.cmake")
file(COPY ${cmake_files} DESTINATION "${CURRENT_PACKAGES_DIR}/share/bcg729")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Bcg729/cmake")
file(GLOB_RECURSE remaining_files "${CURRENT_PACKAGES_DIR}/share/Bcg729/*")
if(NOT remaining_files)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Bcg729")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

file(READ "${SOURCE_PATH}/LICENSE.txt" GPL3)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" [[
bcg729 is dual licensed, and is available either:
 - under a GNU/GPLv3 license, for free (open source). See below.
 - under a proprietary license, for a fee, to be used in closed source applications.
   Contact Belledonne Communications (https://www.linphone.org/contact)
   for any question about costs and services.


]] ${GPL3})
