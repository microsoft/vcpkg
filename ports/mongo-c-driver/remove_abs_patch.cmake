diff --git a/src/libmongoc/CMakeLists.txt b/src/libmongoc/CMakeLists.txt
index 9b2c2f845d..e4357d98a2 100644
--- a/src/libmongoc/CMakeLists.txt
+++ b/src/libmongoc/CMakeLists.txt
@@ -449,7 +449,7 @@ if (NOT WIN32)
    mongoc_get_accept_args (MONGOC_SOCKET_ARG2 MONGOC_SOCKET_ARG3)
 endif ()
 
-set (MONGOC_CC ${CMAKE_C_COMPILER})
+cmake_path(GET CMAKE_C_COMPILER FILENAME MONGOC_CC)
 set (MONGOC_USER_SET_CFLAGS ${CMAKE_C_FLAGS})
 set (MONGOC_USER_SET_LDFLAGS ${CMAKE_EXE_LINKER_FLAGS})
 
