include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/hana
    REF 7f1ae3b1bb52f6eb329300a93dc02309c94dfe01
    SHA512 5fe1962ae270901b58eec83750edd02cc7192b4fae4add72849efbb9989dd5f9a0e3a85f3e3a7525fce38e6ef5bca210993b89d04a1c39bd0421bd0a6f4c92cb
    HEAD_REF develop
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
