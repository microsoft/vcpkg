vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux platform" ON_TARGET "Windows" "OSX")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fadingred/libgpod
    REF 4a8a33ef4bc58eee1baca6793618365f75a5c3fa
    SHA512 b7a120c1106c1205e8de2808de5ac4ff1cf189943017939a5ea4eded4e1ceef44557587e69a8591cc5249f8c8dbf0cbdcce1dd309d33a0e9207b0560abe3ae39
    HEAD_REF master
    PATCHES fix-glibconfigpath.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS ${FEATURE_OPTIONS}
		-DLIBGPOD_BLOB_DIR=${CURRENT_PACKAGES_DIR}/tools
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)