diff --git a/CMakeLists.txt b/CMakeLists.txt
index 8efec25..6007610 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -700,4 +700,13 @@ install(FILES
     DESTINATION "${LIB_INSTALL_DIR}/pkgconfig"
     )
 
+
+include(CMakePackageConfigHelpers)
+
+write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/unofficial-tidy-html5Config-version.cmake"
+  VERSION "${LIBTIDY_VERSION}"
+  COMPATIBILITY SameMajorVersion
+)
+
+install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-tidy-html5Config-version.cmake DESTINATION ${LIB_INSTALL_DIR}/cmake/unofficial-tidy-html5)
 # eof
