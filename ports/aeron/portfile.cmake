if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aeron-io/aeron
    REF "${VERSION}"
    SHA512 6302b235285d897bb58d388c1883145c486f931575174b68161e67a04ae2efb48993d8045855d6e04ba378fdb58050c5339561c85fffb6b222abaa1952103d37
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAERON_INSTALL_TARGETS=ON
        -DAERON_TESTS=OFF
        -DAERON_BUILD_SAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/aeron)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
