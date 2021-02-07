include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

find_path(GDAL_INCLUDE_DIR NAMES gdal.h HINTS ${CURRENT_INSTALLED_DIR})

find_library(GDAL_LIBRARY_DEBUG NAMES gdal_d gdal_i_d gdal NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" NO_DEFAULT_PATH REQUIRED)
find_library(GDAL_LIBRARY_RELEASE NAMES gdal_i gdal NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" NO_DEFAULT_PATH REQUIRED)

select_library_configurations(GDAL)

if (UNIX)
    find_dependency(unofficial-cfitsio CONFIG)
    find_dependency(CURL CONFIG)
    find_dependency(expat CONFIG)
    find_dependency(geos CONFIG)
    find_dependency(hdf5 CONFIG)
    find_dependency(json-c CONFIG)
    find_dependency(geotiff CONFIG)
    find_dependency(liblzma CONFIG)
    find_dependency(libpng CONFIG)
    find_dependency(WebP CONFIG)
    find_dependency(LibXml2)
    find_dependency(netCDF CONFIG)
    find_dependency(OpenJPEG CONFIG)
    find_dependency(proj4 CONFIG)
    find_dependency(unofficial-sqlite3 CONFIG)
    find_dependency(ZLIB)
    
    set(GDAL_LIBRARY ${GDAL_LIBRARY} cfitsio CURL::libcurl expat::expat GEOS::geos GEOS::geos_c
        json-c::json-c geotiff_library liblzma::liblzma WebP::webp WebP::webpdemux WebP::libwebpmux
        WebP::webpdecoder ${LIBXML2_LIBRARIES} netCDF::netcdf openjp2 PROJ::proj unofficial::sqlite3::sqlite3
        ZLIB::ZLIB
    )
    
    if (TARGET hdf5::hdf5-static)
        set(GDAL_LIBRARY ${GDAL_LIBRARY} hdf5::hdf5-static hdf5::hdf5_hl-static)
    else()
        set(GDAL_LIBRARY ${GDAL_LIBRARY} hdf5::hdf5-shared hdf5::hdf5_hl-shared)
    endif()
    
    if (TARGET png_static)
        set(GDAL_LIBRARY ${GDAL_LIBRARY} png_static)
    else()
        set(GDAL_LIBRARY ${GDAL_LIBRARY} png_shared)
    endif()
endif()

set(GDAL_INCLUDE_DIRS ${GDAL_INCLUDE_DIR})
set(GDAL_LIBRARIES ${GDAL_LIBRARY})
