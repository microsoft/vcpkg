vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blaze-lib/blaze
    REF e9724478a5fd29b9c2f8c45f0be95ad774ab4d4f
    SHA512 d1699fffe3013d571e34cf5444714647428be257cad90c4bc6cca8051702ff6d086eb731dca408faaf83b9311df4138f55187673235128fcd3c03029af337a75
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBLAZE_SMP_THREADS=OpenMP
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/blaze/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
