vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ladislav-zezula/CascLib
    REF 07bfe85fd0804cba49f072819af716274d82b855
    SHA512 b333fe6318aa95629aa67613287ac71b1931c6443985e7e52412066d769f7996bffca1c19e890851eba976f572c7a11f14a8ff5fb95433577e1c9af8de0f34af
    HEAD_REF master
    PATCHES
        fix-shared-windows-builds.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" CASC_BUILD_SHARED_LIB)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CASC_BUILD_STATIC_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCASC_BUILD_SHARED_LIB=${CASC_BUILD_SHARED_LIB}
        -DCASC_BUILD_STATIC_LIB=${CASC_BUILD_STATIC_LIB}
        -DCASC_UNICODE=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/CascLib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
