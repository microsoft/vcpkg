diff --git a/CMakeLists.txt b/CMakeLists.txt
index ec5a985c..36564534 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -136,13 +136,6 @@ source_group("folly\\build" FILES
 )
 
 set(FOLLY_SHINY_DEPENDENCIES
-  Boost::chrono
-  Boost::context
-  Boost::date_time
-  Boost::filesystem
-  Boost::program_options
-  Boost::regex
-  Boost::system
   OpenSSL::SSL
   OpenSSL::Crypto
 )
@@ -179,6 +172,7 @@ endif()
 
 set(FOLLY_LINK_LIBRARIES
   ${FOLLY_LINK_LIBRARIES}
+  ${Boost_LIBRARIES}
   Iphlpapi.lib
   Ws2_32.lib
 
@@ -320,7 +314,7 @@ if (BUILD_TESTS)
   )
   target_link_libraries(folly_test_support
     PUBLIC
-      Boost::thread
+      ${Boost_LIBRARIES}
       folly
       ${LIBGMOCK_LIBRARY}
   )
