include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fribidi/fribidi
    REF 58c6cb390a9a18c98b2cbaac555d8ea9352a9e4f
    SHA512 1ec9c19faa87886786ce1589e2c66cab173b48e34d0e43487becc8606001f21f6ed17d0abd1c322fbbcaeb96a47ed882cad228be2e9beb019020ca2a475fc298
    HEAD_REF master
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
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/fribidi RENAME copyright)
