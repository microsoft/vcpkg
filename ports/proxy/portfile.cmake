vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngcpp/proxy
    REF ${VERSION}
    SHA512 acb9f3b6012e2e41aa232da07ee39df9fd2a980d5a38e455662c4b2d5a6407b9dbae87a82d119ed7a036b12997840a6da60c11b5c4f8f01922f16a5616887647
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "msft_proxy4")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
