set(PACKAGE_NAME physics)

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 8f62af3838e9189c3a93fea87991c390ddd4fa0d5c0ecb80f8347bfb2f5892ec73c4bca1ac05d083d2a5adcbbd698e76215d56498bd648834a46af7784e8ce57
   OPTIONS 
   PATCHES
      dependencies.patch
)

if(VCPKG_TARGET_IS_WINDOWS)   
   file(GLOB plugins "${CURRENT_PACKAGES_DIR}/lib/gz-physics-8/engine-plugins/*.dll")
   if (NOT plugins STREQUAL "")
      file(COPY ${plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/engine-plugins/")
      file(REMOVE ${plugins})
   endif()

   file(GLOB plugins_debug "${CURRENT_PACKAGES_DIR}/debug/lib/gz-physics-8/engine-plugins/*.dll")
   if (NOT plugins_debug STREQUAL "")
      file(COPY ${plugins_debug} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/engine-plugins/")
      file(REMOVE ${plugins_debug})
   endif()
endif()
