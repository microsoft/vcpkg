vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BLAKE3-team/BLAKE3
    REF "${VERSION}"
    SHA512 3ea57a86af7357582479ed5d762d368ee52421636c72723b08f528f9bf53637bad0058c5aded0b9a1b9479f374f5d3b110677e00c2b1124a47bfcdac800c2836
    HEAD_REF main
)

# these four files are included in the next release
vcpkg_download_distfile(
    CMAKELISTS_SOURCE_PATH
    URLS https://raw.githubusercontent.com/BLAKE3-team/BLAKE3/76f9339312e1d52632a1cfb9df285c01911d99ce/c/CMakeLists.txt
    FILENAME blake3-CMakeLists.txt
    SHA512 598699b90053fdbe381843f886c213f5e6d03281a9b8c1403726c300e83a9da353879da7170637024663af576e54f74a307049577360ded90d25e11bd852edde
)
vcpkg_download_distfile(
    CMAKECONFIGIN_SOURCE_PATH
    URLS https://raw.githubusercontent.com/BLAKE3-team/BLAKE3/76f9339312e1d52632a1cfb9df285c01911d99ce/c/blake3-config.cmake.in
    FILENAME blake3-config.cmake.in
    SHA512 f9bdb41bd4e4930ab31624f484f895fbda57066a4b3e0a38e7ffefab7343779d1c356fbaf6231643fd069f7a176b840f234f74d9f9ee4167cc430d7bfec0f40f
)
vcpkg_download_distfile(
    PKGCONFIGIN_SOURCE_PATH
    URLS https://raw.githubusercontent.com/BLAKE3-team/BLAKE3/76f9339312e1d52632a1cfb9df285c01911d99ce/c/libblake3.pc.in
    FILENAME libblake3.pc.in
    SHA512 cfbaea63368e655c3ac3357f791b6332ae0241f3fd4f98e19c48f28e633e25a5b1125d1cc6b4815edfd013a76379dffcf9723852a7b76f2910d19dc77e538fa2
)
vcpkg_download_distfile( # we need the dllexport macro (otherwise these files are identical)
    BLAKE3_H_SOURCE_PATH
    URLS https://raw.githubusercontent.com/BLAKE3-team/BLAKE3/76f9339312e1d52632a1cfb9df285c01911d99ce/c/blake3.h
    FILENAME blake3.h
    SHA512 0f9852ff0e527e8fe0d567408c5c100ee3707a1b942ac1fbd78208a68ecfd32814729b5082720278d25d4cf45eb1020fcf3e4199cab0a67a6ca6af4321bcbc3e
)
file(COPY_FILE "${CMAKELISTS_SOURCE_PATH}" "${SOURCE_PATH}/c/CMakeLists.txt")
file(COPY_FILE "${CMAKECONFIGIN_SOURCE_PATH}" "${SOURCE_PATH}/c/blake3-config.cmake.in")
file(COPY_FILE "${PKGCONFIGIN_SOURCE_PATH}" "${SOURCE_PATH}/c/libblake3.pc.in")
file(COPY_FILE "${BLAKE3_H_SOURCE_PATH}" "${SOURCE_PATH}/c/blake3.h")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/c"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
