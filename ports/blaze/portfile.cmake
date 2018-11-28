include(vcpkg_common_functions)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blaze-lib/blaze
    REF bbe39c81b68eb0d8647da703899e1ee4a82cdfd3
    SHA512 84eb8226672d9d11d194d165e7aaa333a0d49ca090bb94472f19242e5f2ad0c3e08a30cdafe055cff51b210b603533f879800bd6784f3ffdb0d9eeca65d58b25
    HEAD_REF master
    PATCHES
        avoid-src-dir-generation.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBLAZE_SMP_THREADS=C++11
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/blaze/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/blaze)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/blaze/LICENSE ${CURRENT_PACKAGES_DIR}/share/blaze/copyright)
