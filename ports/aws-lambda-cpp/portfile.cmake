vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-lambda-cpp
    REF 8bcd8a201f9da613581a2748ca737ab09adbdae5 # v0.2.7
    SHA512 c59310dd839622cfc9ac2a1df5a492e9a6d629b671ed929813dbe51dfe76d4a4e381e78b11b206b66c2bee131a1544c3c8dfc4644981b708b589492763c7ed59
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME aws-lambda-runtime CONFIG_PATH lib/aws-lambda-runtime/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/aws-lambda-runtime")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/aws-lambda-runtime")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
