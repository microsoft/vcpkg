#header-only library with an install target
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF b43855631afdb9f7ccd4b56ed05330a8e3817af1
    SHA512 fe770217f9ced6fbacfb57ab2f57a33ff2c150cdbadb1e4fc4f0bfe39e98b3940f9f22786a5d30ff7967063caadf7c3cf884a398a7eb6b1d0e219577782fc776
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGSL_TEST=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Move package config file (temporary fix)
file(GLOB GSLFILEFOUND "${CURRENT_PACKAGES_DIR}/share/Microsoft.GSL/cmake/*.cmake")
if(GSLFILEFOUND)
    file(INSTALL ${GSLFILEFOUND} DESTINATION "${CURRENT_PACKAGES_DIR}/share/Microsoft.GSL")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Microsoft.GSL/cmake")
endif()
