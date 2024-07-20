ignition_modular_library(NAME common
                         VERSION "4.7.0"
                         SHA512 05aebe014f14afd540abe205a1b3459cb7ef6b6d93289c0672182ee586030ea32cbcc7ce67ba823f8f4233b9cbb027678e0e5f1b6fbc2ce21962690211399cd5
                         OPTIONS -DUSE_EXTERNAL_TINYXML2=ON
                         PATCHES fix-dependencies.patch)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
   file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
