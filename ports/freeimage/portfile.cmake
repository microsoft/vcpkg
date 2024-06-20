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
        rawlib-build-fix.patch
        typedef-xcode.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
          "${CMAKE_CURRENT_LIST_DIR}/FreeImageConfig-static.h"
          "${CMAKE_CURRENT_LIST_DIR}/FreeImageConfig-dynamic.h" 
    DESTINATION "${SOURCE_PATH}"
)

# This is not strictly necessary, but to make sure
# that no "internal" libraries are used we remove them
file(REMOVE_RECURSE
    "${SOURCE_PATH}/Source/LibJPEG"
    "${SOURCE_PATH}/Source/LibPNG"
    "${SOURCE_PATH}/Source/LibTIFF4"
    "${SOURCE_PATH}/Source/ZLib"
    "${SOURCE_PATH}/Source/LibOpenJPEG"
    "${SOURCE_PATH}/Source/LibJXR"
    "${SOURCE_PATH}/Source/LibWebP"
    "${SOURCE_PATH}/Source/LibRawLite"
    "${SOURCE_PATH}/Source/OpenEXR"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license-fi.txt")
