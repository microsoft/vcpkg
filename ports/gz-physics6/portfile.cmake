set(PACKAGE_NAME physics)

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 9f8abbc7cbe64fb3b105ba74cd7dcc999ed1f420a2aeababe4bdb44dd87112cc6df1ae872a20eae776296846de0b52ae9cb44e91f7b33a8ca39f309f1eb72528
   OPTIONS 
   PATCHES
      dependencies.patch
)

if(VCPKG_TARGET_IS_WINDOWS)   
   file(GLOB plugins "${CURRENT_PACKAGES_DIR}/lib/gz-physics-6/engine-plugins/*.dll")
   if (NOT plugins STREQUAL "")
      file(COPY ${plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/bin/engine-plugins/")
      file(REMOVE ${plugins})
   endif()

   file(GLOB plugins_debug "${CURRENT_PACKAGES_DIR}/debug/lib/gz-physics-6/engine-plugins/*.dll")
   if (NOT plugins_debug STREQUAL "")
      file(COPY ${plugins_debug} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/engine-plugins/")
      file(REMOVE ${plugins_debug})
   endif()
endif()
