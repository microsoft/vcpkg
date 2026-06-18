vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gsl-lite/gsl-lite
    REF "v${VERSION}"
    SHA512 9da9b3b29703117e835170f902eace691a31d02d0477eae0026de36d56ffc188e32f3ea769865e3cd501e2880fd0380d9e1f46c7561d94c9f57f8b61d377f4bb
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
