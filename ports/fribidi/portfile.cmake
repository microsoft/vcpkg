vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fribidi/fribidi
    REF abea9f626732a9b10499d76c1cd69ce5457950cc # v1.0.9
    SHA512 5cb28f9e35d0df205c9fb88a56776d371fdd8bca12c211cec282334cfbf12a05e3324cd14a3ae71bcc06e15ce07b06cbe97eaafe1c7368e517a4ce5a4c3a2bcc
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