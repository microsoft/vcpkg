if(GDAL_USE_KEA)
    find_package(Kealib CONFIG REQUIRED)
    add_library(KEA::KEA ALIAS Kealib::Kealib)
    set(GDAL_CHECK_PACKAGE_KEA_NAMES Kealib CACHE INTERNAL "vcpkg")
    set(GDAL_CHECK_PACKAGE_KEA_TARGETS Kealib::Kealib CACHE INTERNAL "vcpkg")
endif()

if(GDAL_USE_WEBP)
    find_package(WebP CONFIG REQUIRED)
    add_library(WEBP::WebP ALIAS WebP::webp)
    set(GDAL_CHECK_PACKAGE_WebP_NAMES WebP CACHE INTERNAL "vcpkg")
    set(GDAL_CHECK_PACKAGE_WebP_TARGETS WebP::webp CACHE INTERNAL "vcpkg")
endif()

if(GDAL_USE_ARROW)
    find_package(Arrow REQUIRED)
    set(ARROW_USE_STATIC_LIBRARIES "${ARROW_BUILD_STATIC}" CACHE INTERNAL "")
    set(GDAL_USE_ARROWDATASET "${ARROW_DATASET}" CACHE INTERNAL "")
    set(GDAL_USE_ARROWCOMPUTE "${ARROW_COMPUTE}" CACHE INTERNAL "")
endif()

if(GDAL_USE_SQLITE3)
    # CMake find module with vcpkg cmake wrapper
    find_package(SQLite3 REQUIRED)
    # .. and inject into GDAL's FindSQLite3.cmake
    set(SQLite3_LIBRARY "${SQLite3_LIBRARIES}")
    set(SQLite3_FOUND FALSE)
    set(SQLITE3_FOUND FALSE)
endif()
