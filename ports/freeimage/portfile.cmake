include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://downloads.sourceforge.net/freeimage/FreeImage3180.zip"
    FILENAME "FreeImage3180.zip"
    SHA512 9d9cc7e2d57552c3115e277aeb036e0455204d389026b17a3f513da5be1fd595421655488bb1ec2f76faebed66049119ca55e26e2a6d37024b3fb7ef36ad4818
)

vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  PATCHES
    "${CMAKE_CURRENT_LIST_DIR}/disable-plugins-depending-on-internal-third-party-libraries.patch"
    "${CMAKE_CURRENT_LIST_DIR}/use-external-jpeg.patch"
    "${CMAKE_CURRENT_LIST_DIR}/use-external-jxrlib.patch"
    "${CMAKE_CURRENT_LIST_DIR}/use-external-libtiff.patch"
    "${CMAKE_CURRENT_LIST_DIR}/use-external-openjpeg.patch"
    "${CMAKE_CURRENT_LIST_DIR}/use-external-png-zlib.patch"
    "${CMAKE_CURRENT_LIST_DIR}/use-external-rawlib.patch"
    "${CMAKE_CURRENT_LIST_DIR}/use-external-webp.patch"
    "${CMAKE_CURRENT_LIST_DIR}/use-external-openexr.patch"
    "${CMAKE_CURRENT_LIST_DIR}/use-freeimage-config-include.patch"
    "${CMAKE_CURRENT_LIST_DIR}/fix-function-overload.patch"
    "${CMAKE_CURRENT_LIST_DIR}/use-typedef-as-already-declared.patch"
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
    OPTIONS
      -DVCPKG_ROOT_DIR=${VCPKG_ROOT_DIR}
      -DTARGET_TRIPLET=${TARGET_TRIPLET}
    OPTIONS_DEBUG
      -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()
file(INSTALL ${SOURCE_PATH}/license-fi.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

