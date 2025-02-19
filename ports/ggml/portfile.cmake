vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/ggml
    REF 9a4acb374565f4146b8d6eb1cffdcd7d437d1ba2
    SHA512 091a794baf669616ee20dc19d0232e64456c07cd50cbe6d81aa68b98f178801be1b62da9eea417e7a563a6b73bb3136777f860c756270569676fb760f2e751ed
    HEAD_REF master
    PATCHES
        0001-fix-cmakelists.patch
        0002-fix-tests.patch
)

if(VCPKG_TARGET_IS_OSX)
    set(GGML_OPENMP OFF)
else()
    set(GGML_OPENMP ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DGGML_CCACHE=OFF
      -DGGML_OPENMP=${GGML_OPENMP}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ggml CONFIG_PATH "lib/cmake/ggml")
vcpkg_copy_pdbs()

if (VCPKG_LIBRARY_LINKAGE MATCHES "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/ggml/ggml-config.cmake"
        "set_and_check(GGML_BIN_DIR \"\${PACKAGE_PREFIX_DIR}/bin\")"
        ""
    )
endif()

if (NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/ggml.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/ggml.pc")
endif()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/ggml.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/ggml.pc")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
