# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO veselink1/refl-cpp
    REF "v${VERSION}"
    SHA512 fcebda170782fd7cc55395fd64012356f416deb1199e2eceee7391c7c1963e39c214e7d99c42e7ca371d6d86923173e916b09e4867cacfaeed4902b5466aed03
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/refl.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
