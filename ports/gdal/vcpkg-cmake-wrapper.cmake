include(SelectLibraryConfigurations)

find_path(GDAL_INCLUDE_DIR
    NAMES gdal.h
    PATHS "${CMAKE_CURRENT_LIST_DIR}/../../include"
    NO_DEFAULT_PATH
)
find_library(GDAL_LIBRARY_DEBUG
    NAMES gdal_d gdal_i_d gdal
    NAMES_PER_DIR
    PATHS "${CMAKE_CURRENT_LIST_DIR}/../../debug/lib"
    NO_DEFAULT_PATH
)
find_library(GDAL_LIBRARY_RELEASE
    NAMES gdal_i gdal
    NAMES_PER_DIR
    PATHS "${CMAKE_CURRENT_LIST_DIR}/../../lib"
    NO_DEFAULT_PATH
)
select_library_configurations(GDAL)

if(NOT GDAL_INCLUDE_DIR OR NOT GDAL_LIBRARY)
    message(FATAL_ERROR "Installation of vcpkg port gdal is broken.")
endif()

set(GDAL_LIBRARY "${GDAL_LIBRARY}" CACHE STRING "")

set(FindGDAL_SKIP_GDAL_CONFIG TRUE)

_find_package(${ARGS})

set(_gdal_dep_find_args "")
if(";${ARGS};" MATCHES ";REQUIRED;")
    list(APPEND _gdal_dep_find_args "REQUIRED")
endif()
function(_gdal_add_dependency target package)
    find_package(${package} ${ARGN} ${_gdal_dep_find_args})
    if(${package}_FOUND)
        foreach(suffix IN ITEMS "" "-shared" "_shared" "-static" "_static" "-NOTFOUND")
            set(dependency "${target}${suffix}")
            if(TARGET ${dependency})
                break()
            endif()
        endforeach()
        if(NOT TARGET ${dependency})
            string(TOUPPER ${package} _gdal_deps_package)
            if(DEFINED ${_gdal_deps_package}_LIBRARIES)
                set(dependency ${${_gdal_deps_package}_LIBRARIES})
            elseif(DEFINED ${package}_LIBRARIES)
                set(dependency ${${package}_LIBRARIES})
            elseif(DEFINED ${_gdal_deps_package}_LIBRARY)
                set(dependency ${${_gdal_deps_package}_LIBRARY})
            elseif(DEFINED ${package}_LIBRARY)
                set(dependency ${${package}_LIBRARY})
            endif()
        endif()
        if(dependency)
            if(TARGET GDAL::GDAL) # CMake 3.14
                set_property(TARGET GDAL::GDAL APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${dependency})
            endif()
            if(NOT GDAL_LIBRARIES STREQUAL "GDAL::GDAL")
                set(GDAL_LIBRARIES "${GDAL_LIBRARIES};${dependency}" PARENT_SCOPE)
            endif()
        else()
            message(WARNING "Did not find which libraries are exported by ${package}")
            set(GDAL_FOUND false PARENT_SCOPE)
        endif()
    else()
        set(GDAL_FOUND false PARENT_SCOPE)
    endif()
endfunction()
if(GDAL_FOUND)
    _gdal_add_dependency(cfitsio  unofficial-cfitsio CONFIG)
    _gdal_add_dependency(CURL::libcurl  CURL CONFIG)
    _gdal_add_dependency(expat::expat  expat CONFIG)
    _gdal_add_dependency(GEOS::geos_c  geos CONFIG)
    _gdal_add_dependency(GIF::GIF  GIF)
    _gdal_add_dependency(hdf5::hdf5  hdf5 CONFIG)
    if(NOT WIN32)
        _gdal_add_dependency(json-c::json-c  json-c CONFIG)
    endif()
    _gdal_add_dependency(geotiff_library  geotiff CONFIG)
    _gdal_add_dependency(JPEG::JPEG  JPEG)
    _gdal_add_dependency(liblzma::liblzma  liblzma CONFIG)
    _gdal_add_dependency(png  libpng CONFIG)
    _gdal_add_dependency(PostgreSQL::PostgreSQL  PostgreSQL)
    _gdal_add_dependency(WebP::webp  WebP CONFIG)
    _gdal_add_dependency(LibXml2::LibXml2  LibXml2)
    _gdal_add_dependency(netCDF::netcdf  netCDF CONFIG)
    _gdal_add_dependency(openjp2  OpenJPEG CONFIG)
    _gdal_add_dependency(PROJ::proj  PROJ4 CONFIG)
    _gdal_add_dependency(unofficial::sqlite3::sqlite3  unofficial-sqlite3 CONFIG)
    _gdal_add_dependency(TIFF::TIFF  TIFF)
    _gdal_add_dependency(ZLIB::ZLIB  ZLIB)
    _gdal_add_dependency(zstd::libzstd  zstd CONFIG)
    list(FIND ARGS "REQUIRED" required)
    if(NOT GDAL_FOUND AND NOT required EQUAL "-1")
        message(FATAL_ERROR "Failed to find dependencies of GDAL")
    endif()
endif()
