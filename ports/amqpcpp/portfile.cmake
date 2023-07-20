vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CopernicaMarketingSoftware/AMQP-CPP
    REF "v${VERSION}"
    SHA512 3af0c0a9aeb98e349cedc7144bfc4ef1b63270d3b20d240b98b990c048402d5d4ea3a2ba28a468aab24ad45544b111809a0692716dc33af493ea5160f132834b
    HEAD_REF master
    PATCHES
        find-openssl.patch
        fix-max_min_macros.patch
)

if(VCPKG_TARGET_IS_LINUX)
    set(LINUX_TCP ON)
else()
    set(LINUX_TCP OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAMQP-CPP_BUILD_SHARED=OFF
        -DAMQP-CPP_LINUX_TCP=${LINUX_TCP}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
