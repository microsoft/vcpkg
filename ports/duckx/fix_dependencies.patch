diff --git a/CMakeLists.txt b/CMakeLists.txt
index f45218659..1ec4250c0 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -9,9 +9,11 @@ endif()
 option(BUILD_SHARED_LIBS "Build shared instead of static library" OFF)
 option(BUILD_SAMPLE "Build provided sample" OFF)
 
-set(HEADERS src/duckx.hpp src/zip.h src/miniz.h
-	src/pugixml.hpp src/pugiconfig.hpp)
-set(SOURCES src/duckx.cpp src/zip.c src/pugixml.cpp)
+find_package(libzip REQUIRED)
+find_package(pugixml REQUIRED)
+
+set(HEADERS src/duckx.hpp)
+set(SOURCES src/duckx.cpp)
 
 if(BUILD_SHARED_LIBS)
     add_library(duckx SHARED ${HEADERS} ${SOURCES})
@@ -19,6 +21,8 @@ else()
     add_library(duckx STATIC ${HEADERS} ${SOURCES})
 endif()
 
+target_link_libraries(duckx PUBLIC libzip::zip pugixml::pugixml)
+
 add_library(duckx::duckx ALIAS duckx)
 
 target_include_directories(duckx PUBLIC
@@ -38,12 +42,22 @@ endif()
 include(GNUInstallDirs)
 install(
     TARGETS duckx
-    EXPORT duckxConfig
+    EXPORT duckxTargets
     ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}${INSTALL_SUFFIX}
     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}${INSTALL_SUFFIX}
     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
     )
-install(EXPORT duckxConfig NAMESPACE duckx:: DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/duckx)
+install(EXPORT duckxTargets NAMESPACE duckx:: DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/duckx)
+include(CMakePackageConfigHelpers)
+configure_package_config_file("${CMAKE_CURRENT_SOURCE_DIR}/duckxConfig.cmake.in" "${CMAKE_CURRENT_BINARY_DIR}/duckxConfig.cmake" 
+                              INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/duckx"
+                              NO_SET_AND_CHECK_MACRO
+                              NO_CHECK_REQUIRED_COMPONENTS_MACRO)
+write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/duckxConfigVersion.cmake" COMPATIBILITY ExactVersion)
+install(FILES "${CMAKE_CURRENT_BINARY_DIR}/duckxConfig.cmake"
+              "${CMAKE_CURRENT_BINARY_DIR}/duckxConfigVersion.cmake"
+        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/duckx")
+        
 install(FILES ${HEADERS} DESTINATION include)
 
 
diff --git a/duckxConfig.cmake.in b/duckxConfig.cmake.in
new file mode 100644
index 000000000..960b03b3b
--- /dev/null
+++ b/duckxConfig.cmake.in
@@ -0,0 +1,6 @@
+@PACKAGE_INIT@
+
+include(CMakeFindDependencyMacro)
+find_dependency(libzip)
+find_dependency(pugixml)
+include("${CMAKE_CURRENT_LIST_DIR}/duckxTargets.cmake")
\ No newline at end of file
