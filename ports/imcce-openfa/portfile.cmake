vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.obspm.fr
    REPO imcce_openfa/openfa
    REF ${VERSION}
    SHA512 8f4cd47c80afcf91514233ff77730d65d264a11d6fa7b6f4eb5382a336577af8ec683a582a14b7aa440fa19f9cdeb780a6010144ce94029b759cb4ee52f7c654
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "openfa" CONFIG_PATH "lib/cmake/openfa")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME readme.md)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
