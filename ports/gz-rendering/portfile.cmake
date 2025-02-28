string(REGEX MATCH "^[0-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}${VERSION_MAJOR}_${VERSION}
   VERSION ${VERSION}
   SHA512 0a0f20eadae0c2ac645f44fccc12842cefe01c07211466b1081abaf3a7390730467d0b8c1ecab9451e7e4e1cca30e3bd352a3e79b5c329323d8e70b7815f105a
   OPTIONS 
   PATCHES
      fix-dependencies.patch
)

if(VCPKG_TARGET_IS_WINDOWS)   
   file(GLOB plugins "${CURRENT_PACKAGES_DIR}/lib/${PORT}-${VERSION_MAJOR}/engine-plugins/*.dll")
   if (NOT plugins STREQUAL "")
      file(COPY ${plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/bin/engine-plugins/")
      file(REMOVE ${plugins})
   endif()

   file(GLOB plugins_debug "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}-${VERSION_MAJOR}/engine-plugins/*.dll")
   if (NOT plugins_debug STREQUAL "")
      file(COPY ${plugins_debug} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/engine-plugins/")
      file(REMOVE ${plugins_debug})
   endif()
endif()
