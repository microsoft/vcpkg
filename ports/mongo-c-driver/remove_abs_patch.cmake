diff --git a/src/libmongoc/CMakeLists.txt b/src/libmongoc/CMakeLists.txt
index 6e295d68fb..54ab225ba7 100644
--- a/src/libmongoc/CMakeLists.txt
+++ b/src/libmongoc/CMakeLists.txt
@@ -474,7 +474,7 @@ if (NOT WIN32)
    mongoc_get_accept_args (MONGOC_SOCKET_ARG2 MONGOC_SOCKET_ARG3)
 endif ()
 
-set (MONGOC_CC ${CMAKE_C_COMPILER})
+cmake_path(GET CMAKE_C_COMPILER FILENAME MONGOC_CC)
 set (MONGOC_USER_SET_CFLAGS ${CMAKE_C_FLAGS})
 set (MONGOC_USER_SET_LDFLAGS ${CMAKE_EXE_LINKER_FLAGS})
 
