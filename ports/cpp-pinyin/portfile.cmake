vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfgitpr/cpp-pinyin
    REF  "${VERSION}"
    SHA512 cdd78cdc493ab352bfd7c5adfb4642bc587fb26f65b4d81a07e7c89c377222a30730f3e800f028106b66cbc35e32709c1a0e470e9737b6ee9718e3ce9da8137a
    HEAD_REF main
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DCPP_PINYIN_BUILD_STATIC=TRUE
            -DCPP_PINYIN_BUILD_TESTS=FALSE
            -DVCPKG_DICT_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT}
    )
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            -DCPP_PINYIN_BUILD_STATIC=FALSE
            -DCPP_PINYIN_BUILD_TESTS=FALSE
            -DVCPKG_DICT_DIR=${CURRENT_PACKAGES_DIR}/share/${PORT}
    )
endif()

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
