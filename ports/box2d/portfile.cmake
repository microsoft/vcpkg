vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erincatto/Box2D
    REF 4d7757feedc9dd36f64393ae08acfd3b9600ac17  #v2.4.0
    SHA512 197f701016c91fda944328e7d867f0a5baa152cce53fa35826986923456af593595bad884008944e041d9ac2e1d769a54eaad4142e19b42a3bb2a2010d814cc9
    HEAD_REF master
    PATCHES
        export-targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
)
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-box2d TARGET_PATH share/unofficial-box2d)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
