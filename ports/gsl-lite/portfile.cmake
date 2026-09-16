vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gsl-lite/gsl-lite
    REF "v${VERSION}"
    SHA512 531ee856196705732c93901e5c600bb40c44c961bd41e7f13316b68147846e4ab75cde82960dddbc6ab69e819f462b183699fd4fc779cf7be94cbec4997dd566
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    CONFIG_PATH "share/cmake/gsl-lite"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/debug"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
