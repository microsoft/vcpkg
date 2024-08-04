set(PACKAGE_NAME rendering)

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 7c14b268694600b8529fef21130b34f516b26baac771c019b4248a67f84420c40d655e0abedf0b36c53b7cdf19941b3f4f3494696c831a83070632d004b30678
   OPTIONS 
   PATCHES
      fix-dependencies.patch
)

if(VCPKG_TARGET_IS_WINDOWS)   
   file(GLOB plugins "${CURRENT_PACKAGES_DIR}/lib/gz-rendering-7/engine-plugins/*.dll")
   if (NOT plugins STREQUAL "")
      file(COPY ${plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/bin/engine-plugins/")
      file(REMOVE ${plugins})
   endif()

   file(GLOB plugins_debug "${CURRENT_PACKAGES_DIR}/debug/lib/gz-rendering-7/engine-plugins/*.dll")
   if (NOT plugins_debug STREQUAL "")
      file(COPY ${plugins_debug} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/engine-plugins/")
      file(REMOVE ${plugins_debug})
   endif()
endif()
