# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/functional
    REF boost-${VERSION}
    SHA512 c0bce73d6abc2e4ca9d2ed25c2990a37d73670b821253c05dd8e1b8532ff5b0a4072bd660c1432625422a1967822c19d51bb17a43912db1eb31bcf4712de5924
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
