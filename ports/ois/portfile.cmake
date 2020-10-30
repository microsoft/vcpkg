# Automatically fail port install for UWP and ARM. Unsure if it is
# supported by library. See here: https://github.com/wgois/OIS/issues/57
vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wgois/OIS
    REF v1.5
    SHA512 5ab1dda7c25c1959ccbbb758ea3fda36bd62ad65f46e2c6b418317a5eb39e0bace52a44ae079dfb69fc58c90df54f8e50d589daae1100ec615325363c9d77513
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
	file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Include files should not be duplicated into the /debug/include directory
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
