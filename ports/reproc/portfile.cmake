vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DaanDeMeyer/reproc
    REF 4bfa5fe500288a0bcd9134533b87dbf8183fd158 # v14.1.0
    SHA512 258046b6b76e8513aa35e6e6a1a5245c9d91eadd0aaa6fe41869080d1b74669350eca86e7025581252327a01c2687d77991721d08554b505d2025e063ae4cc88
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DREPROC++=ON
        -DREPROC_INSTALL_PKGCONFIG=OFF
        -DREPROC_INSTALL_CMAKECONFIGDIR=share
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

foreach(TARGET reproc reproc++)
    vcpkg_fixup_cmake_targets(
        CONFIG_PATH share/${TARGET} 
        TARGET_PATH share/${TARGET}
    )
endforeach()

file(
    INSTALL ${SOURCE_PATH}/LICENSE 
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)
