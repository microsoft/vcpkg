
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/nana)
vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/nanapro/Nana/Nana 1.x/nana 1.4.1.zip"
    FILENAME "nana 1.4.1.zip"
    SHA512 38a4fe4c9f932d0e69753c0c1e28d0c8f7cc1ab73c639b87dd5ba102ed25da1ee04c93ec5d6bb79945f7bc118cc131022604c75c1bb6eaced3a071eb137115cd)

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

file(COPY ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/nana)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nana/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/nana/copyright)
