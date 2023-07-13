vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyobjloader
    REF v2.0.0rc9
    SHA512 e188d6077cb19f9044da9c98c2c4284cad09f4ee745f4746d0df5b22a379d3b32fe20aa998151d6dc08e7f113f50abf80a7509d63c36de46547ce43b5fe1fa54
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        double TINYOBJLOADER_USE_DOUBLE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_INSTALL_DOCDIR:STRING=share/tinyobjloader
        # FEATURES
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/tinyobjloader/cmake)

if("double" IN_LIST FEATURES)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/tiny_obj_loader.h" "#ifdef TINYOBJLOADER_USE_DOUBLE" "#if 1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/tiny_obj_loader.h" "#ifdef TINYOBJLOADER_USE_DOUBLE" "#if 0")
endif()
file(
    REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/lib/tinyobjloader
    ${CURRENT_PACKAGES_DIR}/debug/lib/tinyobjloader
)

vcpkg_copy_pdbs()

# Put the licence file where vcpkg expects it
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinyobjloader/LICENSE ${CURRENT_PACKAGES_DIR}/share/tinyobjloader/copyright)

vcpkg_fixup_pkgconfig()
