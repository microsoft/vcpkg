# header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO abellgithub/delaunator-cpp
    REF "v${VERSION}"
    SHA512 14831b2b86e4a53b7da702d551d93ce555c639721bd5d84733c0bf994e71885d0af5963b8033e278dafa73f59996da4eee03fcd19e78206f0dbcf66077875d8b
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/delaunator-header-only.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/include/delaunator.cpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${SOURCE_PATH}/include/delaunator.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
