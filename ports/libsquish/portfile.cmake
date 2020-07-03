vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsquish
    FILENAME "libsquish-1.15.tgz"
    NO_REMOVE_ONE_LEVEL
    SHA512 5b569b7023874c7a43063107e2e428ea19e6eb00de045a4a13fafe852ed5402093db4b65d540b5971ec2be0d21cb97dfad9161ebfe6cf6e5376174ff6c6c3e7a
    PATCHES fix-export-symbols.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
