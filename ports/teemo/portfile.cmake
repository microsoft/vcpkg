vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/teemo
    REF abfff2b724f3ae9f7968392178005f648fe666e3
    SHA512 56b1791159179c7f84523bf3d4b21f5272fce11843da0f0993e58563414a11637ccee50fe5a520089e16df5e17acf2308c2993266156ee49d9d07b1d7211f151
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" TEEMO_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTEEMO_STATIC:BOOL=${TEEMO_STATIC}
        -DUSE_STATIC_CRT:BOOL=${USE_STATIC_CRT}
        -DBUILD_TESTS:BOOL=OFF
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/teemo")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/teemo)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/share/teemo")
    vcpkg_cmake_config_fixup(CONFIG_PATH share/teemo)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/teemo/teemo.h" "#ifdef TEEMO_STATIC" "#if 1")
else()
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/teemo/teemo.h" "#ifdef TEEMO_STATIC" "#if 0")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()
