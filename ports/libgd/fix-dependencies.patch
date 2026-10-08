diff --git a/CMakeLists.txt b/CMakeLists.txt
index 38b87cf7..459a600d 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -130,11 +130,15 @@ else (USE_EXT_GD)
 	endif (ENABLE_ICONV)
 
 	IF (ENABLE_WEBP)
-		FIND_PACKAGE(WEBP REQUIRED)
+		find_package(WEBP NAMES WebP CONFIG REQUIRED)
+		set(WEBP_INCLUDE_DIR "")
+		set(WEBP_LIBRARIES WebP::webp)
+		list(APPEND PKG_REQUIRES_PRIVATES libwebp)
 	ENDIF (ENABLE_WEBP)
 
 	IF (ENABLE_HEIF)
 		FIND_PACKAGE(HEIF REQUIRED)
+		list(APPEND PKG_REQUIRES_PRIVATES libheif)
 	ENDIF (ENABLE_HEIF)
 
 	IF (ENABLE_AVIF)
@@ -142,6 +146,7 @@ else (USE_EXT_GD)
 		SET(HAVE_LIBAVIF 1)
 		SET(AVIF_LIBRARIES avif)
 		SET(AVIF_FOUND 1)
+		list(APPEND PKG_REQUIRES_PRIVATES libavif)
 	ENDIF (ENABLE_AVIF)
 
 	IF (ENABLE_LIQ)
@@ -169,7 +174,9 @@ else (USE_EXT_GD)
 	endif (ENABLE_XPM)
 
 	if (ENABLE_FONTCONFIG)
-		FIND_PACKAGE(FontConfig REQUIRED)
+		FIND_PACKAGE(Fontconfig REQUIRED)
+		set(FONTCONFIG_INCLUDE_DIR "")
+		set(FONTCONFIG_LIBRARY Fontconfig::Fontconfig)
 	endif (ENABLE_FONTCONFIG)
 
 	if (ENABLE_RAQM)
diff --git a/src/CMakeLists.txt b/src/CMakeLists.txt
index f0fc956d..e111c1aa 100644
--- a/src/CMakeLists.txt
+++ b/src/CMakeLists.txt
@@ -130,7 +130,6 @@ endif()
 SET(LIBS_PRIVATES
 	${ICONV_LIBRARIES}
 	${LIQ_LIBRARIES}
-	${WEBP_LIBRARIES}
 )
 
 set(GD_PROGRAMS gdcmpgif)
