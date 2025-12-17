diff --git a/CMakeLists.txt b/CMakeLists.txt
index 96acbc2e5..f2a08c83d 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -2167,7 +2167,7 @@ install(FILES
 
 # Install the export set for use with the install-tree
 file(RELATIVE_PATH REL_CMAKE_PREFIX "${CMAKE_INSTALL_PREFIX}" "${CMAKE_PREFIX}")
-install(EXPORT casadi-targets DESTINATION ${REL_CMAKE_PREFIX})
+install(EXPORT casadi-targets NAMESPACE casadi:: DESTINATION ${REL_CMAKE_PREFIX})
 
 set(CPACK_PACKAGE_CONTACT "casadi-users@googlegroups.com")
 set(CPACK_PACKAGE_VERSION ${PACKAGE_VERSION_FULL})
diff --git a/docs/examples/cplusplus/cmake_find_package/CMakeLists.txt b/docs/examples/cplusplus/cmake_find_package/CMakeLists.txt
