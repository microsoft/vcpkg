vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
set(VCPKG_POLICY_SKIP_CRT_LINKAGE_CHECK enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erincatto/Box2D
    REF 0f2b0246f39594e93fcc8dde0fe0bb1b20b403f9 #slightly past release v3.1.0
    SHA512 595bb13f49b1c4287ff77a1fe78b9cf4767ddcd15524ab305c5767da3295fc0801b5c62574917e20b926a9947032bb55539c7c823dd9f8f7f02e9d24f6ec76a4
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBOX2D_SAMPLES=OFF
        -DBOX2D_BENCHMARKS=OFF
        -DBOX2D_DOCS=OFF
        -DBOX2D_PROFILE=OFF
        -DBOX2D_VALIDATE=OFF
        -DBOX2D_UNIT_TESTS=OFF
        -DBOX2D_COMPILE_WARNING_AS_ERROR=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/box2d)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
