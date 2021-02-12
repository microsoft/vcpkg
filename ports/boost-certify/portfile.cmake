include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO djarek/certify
    REF a1bd27f2e86ba73d6a64f289f030ec65250edceb
    SHA512 4fe32f2ae417f5e03cce59ebc0952ae133710c779ab371fa273acade98234a6cb28b55eb1c478a5129939a77489d456cf4ee97ff4dfad42b489e02d6d85a38af
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
