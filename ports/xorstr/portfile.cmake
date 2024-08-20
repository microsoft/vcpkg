vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustasMasiulis/xorstr
    REF 066c64eea5104f4e3cfbc49e39031400e086425a # 2021-11-20
    SHA512 b28895c3d51089820ef9bf2dd80b1af5eda2f8463c8374d39bc3b54c4928ecd787977cfd4e207f56cd58e3ec0360e428a52c4b813a8f380258cf29914e32ff50
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/include/xorstr.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
