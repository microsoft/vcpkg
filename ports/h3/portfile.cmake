vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uber/h3
    REF "v${VERSION}"
    SHA512 983204c028b293969062d9013dd36c405158fd26c33b922efc3ebf61999695549da2198aca5fa019d7c9f648fe15dfbfe0bc23d02479608ed287e0cd6c74e532
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_FUZZERS=OFF
        -DBUILD_FILTERS=OFF
        -DBUILD_GENERATORS=OFF
        -DBUILD_TESTING=OFF

        -DENABLE_DOCS=OFF
        -DENABLE_FORMAT=OFF
        -DENABLE_LINTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/h3.pc" " -lh3 -lm" " -lh3")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/h3.pc" " -lh3 -lm" " -lh3")
    endif()
endif()
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/NOTICE")
