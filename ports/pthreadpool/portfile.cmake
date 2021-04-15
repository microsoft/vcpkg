if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Maratyszcza/pthreadpool
    REF b4589998be9a0f794236cf46f1b5b232b2b15ca3 # there is a too much gap from the last release...
    SHA512 8459e489a41c38f4dbe6c4401ebe624c7dc4685181b0852c2284f0e413a192ae9fd1ffd9b43fd97b7fd95dbda4970bc71d8c1eba8e33afa9efea74440f00803d
    PATCHES
        fix-cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPTHREADPOOL_BUILD_TESTS=OFF
        -DPTHREADPOOL_BUILD_BENCHMARKS=OFF
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
