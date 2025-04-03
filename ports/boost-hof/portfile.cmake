# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/hof
    REF boost-${VERSION}
    SHA512 3cf04f835ffc60c2fa3027785fafe627090ba7b789347682f0ad5dd73e546798f3b6d35ca3473398535f37e796bce0e24e3fc133753573565b2f015827501878
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
