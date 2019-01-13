include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/vlfeat
    REF 1.0.1
    SHA512 5aa85fd96408531faabc6894d45b6805c031dac8d64bca9423b61368a50b8b756e9dc830478d3c8df1cc2035fdb72faab82bec8b655905e176c95f9744b09b37
    HEAD_REF cDc
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_STATIC_CRT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_DYNAMIC_LIBS}
        -DBUILD_STATIC_RUNTIME=${BUILD_STATIC_CRT}
        -DBUILD_APPS=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/vlfeat RENAME copyright)
