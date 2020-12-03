#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Taywee/args
    REF 84c7f36ee123aaea0dd6653204435e473f1b088e # accessed on 2020-09-14
    SHA512 c2a2f6571ec7f3cd64e9a1a0346af48c989663663d55a351bb51cd82583dcca3a6ed9f5b7a2686ef490b78efeb36b944dd9a76af0aad83b3dc64d3672c770efb
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DARGS_BUILD_UNITTESTS=OFF
    -DARGS_BUILD_EXAMPLE=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/args)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/args/LICENSE ${CURRENT_PACKAGES_DIR}/share/args/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

vcpkg_copy_pdbs()
