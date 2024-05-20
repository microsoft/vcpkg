vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfcw/libfaketime
    REF v${VERSION}
    SHA512 07c431bee21e31343b680d1322dd529ea276e3cc4dbec61646c12bf5d0263163faf6186efeb36b199e24b655578a493c43e3b7a7acf8eba8b9ff84a1e94d618b
)

vcpkg_configure_make(SOURCE_PATH "${SOURCE_PATH}" SKIP_CONFIGURE)
vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright and usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
