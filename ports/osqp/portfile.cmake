vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osqp/osqp
    REF "v${VERSION}"
    SHA512 d6c0efdc226c096fdfe76dd85522ee4cc9591fafde8de45f3c18453d37bd0509be80f6ba6841adff9216339a0fef1d49072fdc57323e1dd0eb1673f40d3b5d73
    HEAD_REF master
)
vcpkg_from_github(
    OUT_SOURCE_PATH MODULES_SOURCE_PATH
    REPO osqp/qdldl
    REF 7d16b70a10a152682204d745d814b6eb63dc5cd2
    SHA512 9174269e6fb52a8184a12d8ff62c028f5e5065ebe688af92c02cd98b0cd87e015709b2a5a1a8c8a33719b2133e52261f9949fbb678f5a8bb98ae68bd0066c099
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/lin_sys/direct/qdldl/qdldl_sources")
file(RENAME "${MODULES_SOURCE_PATH}" "${SOURCE_PATH}/lin_sys/direct/qdldl/qdldl_sources")


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
