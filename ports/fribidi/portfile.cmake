vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fribidi/fribidi
    REF 5464c284034da9c058269377b7f5013bb089f553 # v1.0.10
    SHA512 82e42b022f23d6ecebac5071f997c9f46db6aa41c36f87a7f1a28a79b4ccaada10d68b233bbf687c552fc94d91f4b47161e0ef4909fd1de0b483089f1d1377f9
    HEAD_REF master
    PATCHES fix-win-static-suffix.patch
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Ddocs=false
        --backend=ninja
)

vcpkg_install_meson()
vcpkg_copy_pdbs()

file(GLOB EXE_FILES
    "${CURRENT_PACKAGES_DIR}/bin/*.exe"
    "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe"
)
if (EXE_FILES)
    file(REMOVE ${EXE_FILES})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)