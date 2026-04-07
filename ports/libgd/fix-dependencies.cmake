diff --git a/CMakeLists.txt b/CMakeLists.txt
index bab784a..76c20e8 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -134,7 +134,10 @@ else (USE_EXT_GD)
 	endif (ENABLE_ICONV)
 
 	IF (ENABLE_WEBP)
-		FIND_PACKAGE(WEBP REQUIRED)
+		find_package(WEBP NAMES WebP CONFIG REQUIRED)
+		set(WEBP_INCLUDE_DIR "")
+		set(WEBP_LIBRARIES WebP::webp)
+		list(APPEND PKG_REQUIRES_PRIVATES libwebp)
 	ENDIF (ENABLE_WEBP)
 
 	IF (ENABLE_HEIF)
@@ -173,7 +176,9 @@ else (USE_EXT_GD)
 	endif (ENABLE_XPM)
 
 	if (ENABLE_FONTCONFIG)
-		FIND_PACKAGE(FontConfig REQUIRED)
+		FIND_PACKAGE(Fontconfig REQUIRED)
+		set(FONTCONFIG_INCLUDE_DIR "")
+		set(FONTCONFIG_LIBRARY Fontconfig::Fontconfig)
 	endif (ENABLE_FONTCONFIG)
 
 	if (ENABLE_RAQM)
diff --git a/src/CMakeLists.txt b/src/CMakeLists.txt
index 4cb56eb..74fa26b 100644
--- a/src/CMakeLists.txt
+++ b/src/CMakeLists.txt
@@ -125,7 +125,6 @@ endif()
 SET(LIBS_PRIVATES
 	${ICONV_LIBRARIES}
 	${LIQ_LIBRARIES}
-	${WEBP_LIBRARIES}
 )
 
 set(GD_PROGRAMS gdcmpgif)
