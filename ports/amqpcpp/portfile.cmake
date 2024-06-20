vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CopernicaMarketingSoftware/AMQP-CPP
    REF "v${VERSION}"
    SHA512 0fb280bfea6dc665d44efa7321a4b69c130a5f0b10be7ada7909e00ec8a3ca0b98125bd96475386f1b3627bac9f8e5c9bbd71b462868b46919737da32e021cb4
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
