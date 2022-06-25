ignition_modular_library(NAME common
                         VERSION "3.9.0"
                         SHA512 1bae86efd7da10ac517d67a75ad1b612ea2046128eb75e0f0a134ffff7cc76431e850a9b46fdb7dc6603e2acb044f4204fdedaf38fc7bff82883db3f36830fb9
                         OPTIONS -DUSE_EXTERNAL_TINYXML2=ON
                         PATCHES fix-dependencies.patch)

# Remove non-relocatable helper scripts (see https://github.com/ignitionrobotics/ign-common/issues/82)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/ign_remotery_vis" "${CURRENT_PACKAGES_DIR}/debug/bin/ign_remotery_vis")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
   file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
