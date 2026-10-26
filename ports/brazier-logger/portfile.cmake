vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brazier-tech/brazier-logger
    REF 1cbb6a8e978df514240da22a916564841efb82cd
    SHA512 ee34a46cd4a087b4696348452a40e5c0f7a771144bed73e718d3f9939371c6848902804844d4027d61bf7c897f29f786317398d64fed66ca5c04e6dc924a6f55 
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME brazier-logger CONFIG_PATH share/brazier-logger)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/COPYING")