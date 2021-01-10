include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

ignition_modular_library(NAME common
                         VERSION "3.9.0"
                         SHA512 8d052850cbb125e334494c9ad9b234c371fe310327dba997515651f29479d747dffa55b0aa822f2a78e6317a4df2d41389c7a07165cdc08894fdfb116e4d9756)

# Remove non-relocatable helper scripts (see https://github.com/ignitionrobotics/ign-common/issues/82)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/ign_remotery_vis" "${CURRENT_PACKAGES_DIR}/debug/bin/ign_remotery_vis")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
   file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
