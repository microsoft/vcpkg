ignition_modular_library(NAME common
                         VERSION "3.14.1"
                         SHA512 5f83685b67cb0b8e295136f74a681e2ca5f00a730b0a221f0c00cab5f9049c84692185fb5924ab29cd07cbdf85450e81dfcdc984fc8af4ed4cc549b2fe2f9a6e
                         OPTIONS -DUSE_EXTERNAL_TINYXML2=ON
                         PATCHES fix-dependencies.patch)

# Remove non-relocatable helper scripts (see https://github.com/ignitionrobotics/ign-common/issues/82)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/ign_remotery_vis" "${CURRENT_PACKAGES_DIR}/debug/bin/ign_remotery_vis")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
   file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
