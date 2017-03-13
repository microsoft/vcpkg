
include(vcpkg_common_functions)
set(VERSION 66be23c9204c5567d1c51e6f57ba23bffa517a7c)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/nana-${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/cnjinhao/nana/archive/${VERSION}.zip"
    FILENAME "nana-${VERSION}.zip"
    SHA512 07a611850ebdd3be29fcc5dd199511af859da9e6ad9365b41900ab669e2c1c506c9c264a13a35d60b2d7906b577c8412f2423d67595b75f4de6f6c65b1db1f37)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-linking.patch")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
        -DNANA_CMAKE_ENABLE_PNG=ON
        -DNANA_CMAKE_ENABLE_JPEG=ON
    OPTIONS_DEBUG
        -DNANA_CMAKE_INSTALL_INCLUDES=OFF)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/nana.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/nana.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nana)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nana/LICENSE ${CURRENT_PACKAGES_DIR}/share/nana/copyright)
