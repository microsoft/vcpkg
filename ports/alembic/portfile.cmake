vcpkg_buildpath_length_warning(37)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alembic/alembic
    REF 1.7.12
    SHA512 e05e0b24056c17f01784ced1f9606a269974de195f1aca8a6fce2123314e7ee609f70df77ac7fe18dc7f0c04fb883d38cc7de9b963caacf9586aaa24d4ac6210
    HEAD_REF master
    PATCHES
        fix-C1083.patch
        fix-find-openexr-ilmbase.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DUSE_HDF5=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Alembic)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB DEBUG_EXE ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${EXE})
file(REMOVE ${DEBUG_EXE})
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/Alembic.dll ${CURRENT_PACKAGES_DIR}/bin/Alembic.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/Alembic.dll ${CURRENT_PACKAGES_DIR}/debug/bin/Alembic.dll)

file(READ ${CURRENT_PACKAGES_DIR}/share/Alembic/AlembicTargets-debug.cmake DEBUG_CONFIG)
string(REPLACE "\${_IMPORT_PREFIX}/debug/lib/Alembic.dll"
               "\${_IMPORT_PREFIX}/debug/bin/Alembic.dll" DEBUG_CONFIG "${DEBUG_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/Alembic/AlembicTargets-debug.cmake "${DEBUG_CONFIG}")

file(READ ${CURRENT_PACKAGES_DIR}/share/Alembic/AlembicTargets-release.cmake RELEASE_CONFIG)
string(REPLACE "\${_IMPORT_PREFIX}/lib/Alembic.dll"
               "\${_IMPORT_PREFIX}/bin/Alembic.dll" RELEASE_CONFIG "${RELEASE_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/Alembic/AlembicTargets-release.cmake "${RELEASE_CONFIG}")

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/Alembic/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/Alembic/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/Alembic/copyright)
