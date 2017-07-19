include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openjpeg-2.1.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/uclouvain/openjpeg/archive/v2.1.2.zip"
    FILENAME "openjpeg-2.1.2.zip"
    SHA512 45518b92b2a8e7218ab3efdebe1acf0437c01ab2e4d5769da17103a76ba38a7305fb36d0ceeca0576d53c071a3482d2d3f01d6e48a569191290bfba9274ef7b4
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_CODEC:BOOL=OFF
            -DOPENJPEG_INSTALL_PACKAGE_DIR=share/openjpeg
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()

file(READ ${CURRENT_PACKAGES_DIR}/include/openjpeg-2.1/openjpeg.h OPENJPEG_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined(OPJ_STATIC)" "1" OPENJPEG_H "${OPENJPEG_H}")
else()
    string(REPLACE "defined(OPJ_STATIC)" "0" OPENJPEG_H "${OPENJPEG_H}")
endif()
string(REPLACE "defined(DLL_EXPORT)" "0" OPENJPEG_H "${OPENJPEG_H}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/openjpeg-2.1/openjpeg.h "${OPENJPEG_H}")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openjpeg)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openjpeg/LICENSE ${CURRENT_PACKAGES_DIR}/share/openjpeg/copyright)

vcpkg_copy_pdbs()
