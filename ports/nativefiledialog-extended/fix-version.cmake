diff --git a/src/CMakeLists.txt b/src/CMakeLists.txt
index 740b484..e4397a4 100644
--- a/src/CMakeLists.txt
+++ b/src/CMakeLists.txt
@@ -128,6 +128,14 @@ set_target_properties(${TARGET_NAME} PROPERTIES
 
 if (NFD_INSTALL)
   include(GNUInstallDirs)
+  include(CMakePackageConfigHelpers)
+
+  write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}-config-version.cmake"
+    VERSION "${PROJECT_VERSION}"
+    COMPATIBILITY SameMajorVersion
+  )
+
+  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}-config-version.cmake" DESTINATION lib/cmake/${TARGET_NAME})
 
   install(TARGETS ${TARGET_NAME} EXPORT ${TARGET_NAME}-export
     LIBRARY DESTINATION ${LIB_INSTALL_DIR} ARCHIVE DESTINATION ${LIB_INSTALL_DIR} PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}    
