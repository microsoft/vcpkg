set(PACKAGE_NAME gui)

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 29f37a31bbf90dd35f37e80053c1aff9fb404b7a09c8c10e640da505cc6261387e6ce77e3bf379a911e6131c684f866cf1ef8d83777112b3c7f148b1f95cc72f
   OPTIONS 
   PATCHES
      dependencies.patch
)

if(VCPKG_TARGET_IS_WINDOWS)   
   file(GLOB plugins "${CURRENT_PACKAGES_DIR}/lib/gz-gui-7/plugins/*.dll")
   if (NOT plugins STREQUAL "")
      file(COPY ${plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/engine-plugins/")
      file(REMOVE ${plugins})
   endif()

   file(GLOB plugins_debug "${CURRENT_PACKAGES_DIR}/debug/lib/gz-gui-7/plugins/*.dll")
   if (NOT plugins_debug STREQUAL "")
      file(COPY ${plugins_debug} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/engine-plugins/")
      file(REMOVE ${plugins_debug})
   endif()

    # Lacking pc files for Qt
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
