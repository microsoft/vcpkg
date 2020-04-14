#header-only library with an install target
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF 044849d6fa0cdeb47a3ea51ee02f557b7684e312
    SHA512 084e4995d4b19e421da3bcaddae5296e8557a01a785f2ba4a75e13708411a744c82517e888f0d6d97ac7b2adefe415e6accd62fe8cce8ff2f7034e8d1ea96f9a
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
