vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDSoap
    REF fb0e905e242c2044fd25683a406eb6d369db052f # kdsoap-1.9.0
    SHA512 30f78602702f2bb77f72bf0637b413d70976cf10789b18d1eb9c097f6b3821b86e75d0ae921454b2d39b7d023f479dc089cde1915533a37054f9b26893f611d3
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KDSoap_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKDSoap_STATIC=${KDSoap_STATIC}
        -DKDSoap_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "KDSoap" CONFIG_PATH "lib/cmake/KDSoap")

vcpkg_copy_tools(TOOL_NAMES "kdwsdl2cpp" AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
