vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fribidi/fribidi
    REF 5464c284034da9c058269377b7f5013bb089f553 # v1.0.10
    SHA512 82e42b022f23d6ecebac5071f997c9f46db6aa41c36f87a7f1a28a79b4ccaada10d68b233bbf687c552fc94d91f4b47161e0ef4909fd1de0b483089f1d1377f9
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Ddocs=false
        -Dbin=false
        -Dtests=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Define static macro
file(READ ${CURRENT_PACKAGES_DIR}/include/fribidi/fribidi-common.h FRIBIDI_COMMON_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "#ifndef FRIBIDI_LIB_STATIC" "#if 0" FRIBIDI_COMMON_H "${FRIBIDI_COMMON_H}")
else()
    string(REPLACE "#ifndef FRIBIDI_LIB_STATIC" "#if 1" FRIBIDI_COMMON_H "${FRIBIDI_COMMON_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/fribidi/fribidi-common.h "${FRIBIDI_COMMON_H}")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)