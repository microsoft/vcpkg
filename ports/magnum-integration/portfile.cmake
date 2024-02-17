vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/magnum-integration
    REF v2020.06
    SHA512 0b615acdb49ed55bd678a5fb019b1a8ccf522084f3114b2b8dd7e121c27d39ae2aab2879a2e2fa8b083163be711a86f64202fcf380413dec0c705fffd7d649c5
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        bullet WITH_BULLET
        eigen  WITH_EIGEN
        glm    WITH_GLM
        imgui  WITH_IMGUI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_STATIC=${BUILD_STATIC}
        -DMAGNUM_PLUGINS_DEBUG_DIR=${CURRENT_INSTALLED_DIR}/debug/bin/magnum-d
        -DMAGNUM_PLUGINS_RELEASE_DIR=${CURRENT_INSTALLED_DIR}/bin/magnum
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME MagnumIntegration CONFIG_PATH share/cmake/MagnumIntegration)

# Debug includes and share are the same as release
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Clean up empty directories
if("${FEATURES}" STREQUAL "core")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/lib"
        "${CURRENT_PACKAGES_DIR}/debug"
    )
    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
else()
    file(GLOB FILES "${CURRENT_PACKAGES_DIR}/debug/*")
    list(LENGTH FILES COUNT)
    if(COUNT EQUAL 0)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
    endif()
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
   file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
   file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)

vcpkg_copy_pdbs()
