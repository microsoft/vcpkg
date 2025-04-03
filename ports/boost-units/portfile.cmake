# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/units
    REF boost-${VERSION}
    SHA512 aee7afdf14696e5e6d9b940eb0725baabb8d16e0ad087de69ec1c01b51abbcb3e4958bc80787826d0bb861abcd4763e6b064f9a70f680dfbf989ae7933d3ecd6
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
