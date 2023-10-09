set(PACKAGE_NAME common)

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 022f5f68cdc134fa84dc22b49dc43e5c62d6e987e7fd63630586716e43fb2aad57ab4fb470ea1c3884c79b910d403a94a4d47ac24ffbb6f3b89b36c5b0e708f8
   OPTIONS 
      -DUSE_EXTERNAL_TINYXML2=ON
   PATCHES
      fix-dependencies.patch
)


# Remove non-relocatable helper scripts (see https://github.com/ignitionrobotics/ign-common/issues/82)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/ign_remotery_vis" "${CURRENT_PACKAGES_DIR}/debug/bin/ign_remotery_vis")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
   file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
