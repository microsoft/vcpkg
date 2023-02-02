vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO freeimage/Source%20Distribution
    REF 3.18.0
    FILENAME "FreeImage3180.zip"
    SHA512 9d9cc7e2d57552c3115e277aeb036e0455204d389026b17a3f513da5be1fd595421655488bb1ec2f76faebed66049119ca55e26e2a6d37024b3fb7ef36ad4818
    PATCHES
        disable-plugins-depending-on-internal-third-party-libraries.patch
        use-external-jpeg.patch
        use-external-jxrlib.patch
        use-external-libtiff.patch
        use-external-openjpeg.patch
        use-external-png-zlib.patch
        use-external-rawlib.patch
        use-external-webp.patch
        use-external-openexr.patch
        use-freeimage-config-include.patch
        fix-function-overload.patch
        use-typedef-as-already-declared.patch
        use-functions-to-override-libtiff-warning-error-handlers.patch
        remove_auto_ptr.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/FreeImageConfig-static.h DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/FreeImageConfig-dynamic.h DESTINATION ${SOURCE_PATH})

# This is not strictly necessary, but to make sure
# that no "internal" libraries are used we remove them
file(REMOVE_RECURSE ${SOURCE_PATH}/Source/LibJPEG)
file(REMOVE_RECURSE ${SOURCE_PATH}/Source/LibPNG)
file(REMOVE_RECURSE ${SOURCE_PATH}/Source/LibTIFF4)
file(REMOVE_RECURSE ${SOURCE_PATH}/Source/ZLib)
file(REMOVE_RECURSE ${SOURCE_PATH}/Source/LibOpenJPEG)
file(REMOVE_RECURSE ${SOURCE_PATH}/Source/LibJXR)
file(REMOVE_RECURSE ${SOURCE_PATH}/Source/LibWebP)
file(REMOVE_RECURSE ${SOURCE_PATH}/Source/LibRawLite)
file(REMOVE_RECURSE ${SOURCE_PATH}/Source/OpenEXR)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
      -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/license-fi.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
