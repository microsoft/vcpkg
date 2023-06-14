vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PaddlePaddle/FlyCV
    REF "release/v1.2.0"
    SHA512 6f40f00f54a3d10da3f49a3c070e6cc8319c3d429d3fe4651e3ca1c55973d9610b64e05a5dec5a33dd8e6c7c293117a1d1b85e2833e07faebfd591f8fed3da14
    HEAD_REF develop
    PATCHES
        int64_and_install.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH JPEG_SOURCE_PATH
    REPO libjpeg-turbo/libjpeg-turbo
    REF 2.1.4
    SHA512 d3e92d614168355827e0ed884ff847cc7df8f6f1fb7b673c6c99afdf61fdfc0372afe5d30fdbf5e743335e2a7a27ca9f510c67d213e5cb2315a8d946e9414575
    HEAD_REF main
)
file(COPY ${JPEG_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/third_party/libjpeg-turbo)

vcpkg_from_github(
    OUT_SOURCE_PATH PNG_SOURCE_PATH
    REPO glennrp/libpng
    REF v1.6.39
    SHA512 d61408cee5850582baa57166547ccab6cc171bc809076e53494ace26157fd7787c3209e3b757fd68c541bfb95afe309745d887fb5cd2005b2024af7355c809a0
    HEAD_REF main
)
file(COPY ${PNG_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/third_party/libpng)

vcpkg_from_github(
    OUT_SOURCE_PATH ZLIB_SOURCE_PATH
    REPO madler/zlib
    REF v1.2.9
    SHA512 c38fee5a729cf57801b04d64d10c3727a4732dd47c69d9d107bc862a2e66012afdff07c2e2829d3b7b4337a31e65cc8f921a5a8a23a7e12c6730b2cbb0b9a7c7
    HEAD_REF main
)
file(COPY ${ZLIB_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/third_party/zlib)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TEST=OFF
        -DWITH_LIB_PNG=ON
        -DWITH_LIB_JPEG_TURBO=ON
        -DBUILD_C=ON
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
