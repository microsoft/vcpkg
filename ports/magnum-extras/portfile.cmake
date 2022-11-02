vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mosra/magnum-extras
    REF v2020.06
    SHA512 7419af84a6de72f666a9bd12a325c4b40f9e2a25fec3d0b22c348faab0a402b62fa782231b9b12180d84f4ab2508b02df25a97713948bdd2f21c9e8cb831fa25
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

# Handle features
set(_COMPONENT_FLAGS "")
foreach(_feature IN LISTS ALL_FEATURES)
    if(_feature)
        # Uppercase the feature name and replace "-" with "_"
        string(TOUPPER "${_feature}" _FEATURE)
        string(REPLACE "-" "_" _FEATURE "${_FEATURE}")

        # Turn "-DWITH_*=" ON or OFF depending on whether the feature
        # is in the list.
        if(_feature IN_LIST FEATURES)
            list(APPEND _COMPONENT_FLAGS "-DWITH_${_FEATURE}=ON")
        else()
            list(APPEND _COMPONENT_FLAGS "-DWITH_${_FEATURE}=OFF")
        endif()
    endif()
endforeach()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${_COMPONENT_FLAGS}
        -DBUILD_STATIC=${BUILD_STATIC}
        -DMAGNUM_PLUGINS_DEBUG_DIR=${CURRENT_INSTALLED_DIR}/debug/bin/magnum-d
        -DMAGNUM_PLUGINS_RELEASE_DIR=${CURRENT_INSTALLED_DIR}/bin/magnum
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME MagnumExtras CONFIG_PATH share/cmake/MagnumExtras)

# Messages to the user
if("ui" IN_LIST FEATURES)
    message(WARNING "It is recommended to install one of magnum-plugins[freetypefont,harfbuzzfont,stbtruetypefont] to have the UI library working out of the box")
endif()

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
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
   file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
   file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)

vcpkg_copy_pdbs()
