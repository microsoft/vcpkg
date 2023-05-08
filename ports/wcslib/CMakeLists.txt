# WCSLIB CMakeLists.txt

# Suppress warning about WIN32 no longer being defined on Cygwin:
SET(CMAKE_LEGACY_CYGWIN_WIN32 0)

PROJECT(WCSLIB)
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.0)

# Allow @rpath token in target install name on Macs.
# See "cmake --help-policy CMP0042" for more information.
IF(POLICY CMP0042)
  CMAKE_POLICY(SET CMP0042 NEW)
ENDIF()

# See "cmake --help-policy CMP0053" for more information.
IF(POLICY CMP0053)
  CMAKE_POLICY(SET CMP0053 NEW)
ENDIF()

INCLUDE (${CMAKE_ROOT}/Modules/CheckFunctionExists.cmake)
INCLUDE(CheckTypeSize)

# Allow the developer to select if Dynamic or Static libraries are built
OPTION (BUILD_SHARED_LIBS "Build Shared Libraries" ON)

# Define project version
SET(${PROJECT_NAME}_MAJOR_VERSION 7)
SET(${PROJECT_NAME}_MINOR_VERSION 12)
SET(${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_MAJOR_VERSION}.${${PROJECT_NAME}_MINOR_VERSION})
SET(LIB_NAME wcs)

SET (LIB_TYPE STATIC)
IF (BUILD_SHARED_LIBS)
  SET (LIB_TYPE SHARED)
ENDIF (BUILD_SHARED_LIBS)


# Find CFITSIO includes and libraries
FIND_PATH(CFITSIO_INCLUDE_DIR fitsio.h
  HINTS
      ${CURRENT_INSTALLED_DIR}
  PATH_SUFFIXES
      include
      include/cfitsio
      include/libcfitsio0)

FIND_LIBRARY(CFITSIO_LIBRARY cfitsio
  HINTS
      ${CURRENT_INSTALLED_DIR}
  PATH_SUFFIXES
      lib)
FIND_LIBRARY(M_LIBRARY m)
MARK_AS_ADVANCED(CFITSIO_INCLUDE_DIR CFITSIO_LIBRARY M_LIBRARY)

IF(CMAKE_VERSION VERSION_LESS "3.0.0")
  find_package_handle_standard_args(CFITSIO DEFAULT_MSG
    CFITSIO_LIBRARY M_LIBRARY CFITSIO_INCLUDE_DIR)
ELSE()
  INCLUDE(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(CFITSIO
    REQUIRED_VARS CFITSIO_LIBRARY M_LIBRARY CFITSIO_INCLUDE_DIR
    VERSION_VAR CFITSIO_VERSION_STRING)
ENDIF(CMAKE_VERSION VERSION_LESS "3.0.0")

SET(CFITSIO_INCLUDE_DIRS ${CFITSIO_INCLUDE_DIR})
SET(CFITSIO_LIBRARIES ${CFITSIO_LIBRARY} ${M_LIBRARY})

CHECK_FUNCTION_EXISTS(sincos  HAVE_SINCOS)
CHECK_TYPE_SIZE("long long int" SIZEOF_LONG_LONG_INT)
CHECK_TYPE_SIZE("long int" SIZEOF_LONG_INT)
CHECK_TYPE_SIZE("int" SIZEOF_INT)

IF(HAVE_SINCOS)
  SET(SINCOS_LINE "#define HAVE_SINCOS 1")
ELSE()
  SET(SINCOS_LINE "#undef HAVE_SINCOS")
ENDIF()

IF(SIZEOF_LONG_LONG_INT EQUAL "8")
  SET(INT64_LINE "#define WCSLIB_INT64 long long int")
ELSEIF(SIZEOF_LONG EQUAL "8")
  SET(INT64_LINE "#define WCSLIB_INT64 long int")
ELSEIF(SIZEOF_INT EQUAL "8")
  SET(INT64_LINE "#define WCSLIB_INT64 int")
ELSE()
  SET(INT64_LINE "#undef WCSLIB_INT64")
ENDIF()

FILE(WRITE ${CMAKE_SOURCE_DIR}/wcsconfig.h
  "#define HAVE_WCSLIB_VERSION\n"
  "#define WCSLIB_VERSION 7.12\n"
  "${SINCOS_LINE}\n"
  "${INT64_LINE}\n")

FILE(GLOB_RECURSE H_FILES RELATIVE "${CMAKE_SOURCE_DIR}" "*.h")
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR})
INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/C)
INCLUDE_DIRECTORIES(${CFITSIO_INCLUDE_DIRS})

IF (USE_PTHREADS)
    FIND_PACKAGE(pthreads REQUIRED)
    INCLUDE_DIRECTORIES(${PTHREADS_INCLUDE_DIR})
    ADD_DEFINITIONS(-D_REENTRANT)
ENDIF()

SET(SRC_FILES
    C/cel.c
    C/dis.c
    C/lin.c
    C/log.c
    C/prj.c
    C/spc.c
    C/sph.c
    C/spx.c
    C/tab.c
    C/wcs.c
    C/wcserr.c
    C/wcsfix.c
    C/wcshdr.c
    C/wcstrig.c
    C/wcsprintf.c
    C/wcsutil.c
    C/wcsunits.c

    # C/wcsulex.c # Use flexed version
    # C/wcsutrn.c # Use flexed version
    # C/wcspih.c  # Use flexed version
    # C/wcsbth.c  # Use flexed version
    # C/fitshdr.c # Use flexed version

    # C/getwcstab.c # Redefines fits_read_wcstab in libcfitsio

    C/flexed/wcsulex.c
    C/flexed/wcsbth.c
    C/flexed/fitshdr.c
    C/flexed/wcsutrn.c
    C/flexed/wcspih.c

    # pgsbox/cpgsbox.c
    # pgsbox/pgwcsl.c
    # pgsbox/cpgtest.c

    # Fortran/sph_f.c
    # Fortran/prj_f.c
    # Fortran/spc_f.c
    # Fortran/lin_f.c
    # Fortran/tab_f.c
    # Fortran/cel_f.c
    # Fortran/wcs_f.c
    # Fortran/wcshdr_f.c
    # Fortran/wcserr_f.c
    # Fortran/fitshdr_f.c
    # Fortran/getwcstab_f.c
    # Fortran/wcsunits_f.c
    # Fortran/dis_f.c
    # Fortran/spx_f.c
    # Fortran/wcsfix_f.c
    # Fortran/log_f.c

    # C/test/tspc.c
    # C/test/tsph.c
    # C/test/tbth1.c
    # C/test/tlog.c
    # C/test/tfitshdr.c
    # C/test/tdis1.c
    # C/test/twcsmix.c
    # C/test/ttab2.c
    # C/test/tspcaips.c
    # C/test/twcssub.c
    # C/test/ttab1.c
    # C/test/tsphdpa.c
    # C/test/tprj2.c
    # C/test/tdis2.c
    # C/test/tspcspxe.c
    # C/test/twcsfix.c
    # C/test/twcscompare.c
    # C/test/twcshdr.c
    # C/test/twcs_locale.c
    # C/test/twcs.c
    # C/test/ttab3.c
    # C/test/tlin.c
    # C/test/tprj1.c
    # C/test/tpih1.c
    # C/test/tdisiter.c
    # C/test/tpthreads.c
    # C/test/tspctrne.c
    # C/test/tpih2.c
    # C/test/tcel1.c
    # C/test/tspx.c
    # C/test/tcel2.c
    # C/test/tunits.c
    # C/test/twcstab.c

    # utils/HPXcvt.c
    # utils/sundazel.c
    # utils/tofits.c
    # utils/fitshdr.c
    # utils/wcsware.c
    # utils/wcsgrid.c
)

SET(LIB_DESTINATION "${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX}")
SET(INCLUDE_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/include/wcslib")

ADD_LIBRARY(${LIB_NAME} ${LIB_TYPE})
TARGET_SOURCES(${LIB_NAME} PRIVATE ${SRC_FILES})
TARGET_SOURCES(${LIB_NAME} PUBLIC ${H_FILES})
TARGET_LINK_LIBRARIES(${LIB_NAME} ${CFITSIO_LIBRARIES})

SET_TARGET_PROPERTIES(${LIB_NAME} PROPERTIES VERSION ${${PROJECT_NAME}_VERSION} SOVERSION ${${PROJECT_NAME}_MAJOR_VERSION})
install(TARGETS ${LIB_NAME} DESTINATION ${LIB_DESTINATION})
install(TARGETS ${LIB_NAME}
                            RUNTIME DESTINATION bin
                            LIBRARY DESTINATION lib
                            ARCHIVE DESTINATION lib)
install(FILES ${H_FILES} DESTINATION include/wcslib)

# Only build test code and executables if building a shared library:
IF (BUILD_SHARED_LIBS)
    ENABLE_TESTING()
ENDIF(BUILD_SHARED_LIBS)

FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/wcslib.pc
  "prefix=@CMAKE_INSTALL_PREFIX@\n"
  "exec_prefix=@CMAKE_INSTALL_PREFIX@\n"
  "libdir=@LIB_DESTINATION@\n"
  "includedir=@INCLUDE_INSTALL_DIR@\n"
  "\n"
  "Name: WCSLIB\n"
  "Description: An implementation of the FITS World Coordinate System standard\n"
  "Version: @PACKAGE_VERSION@\n"
  "Libs: -L${libdir} @PKG_CONFIG_LIBS@\n"
  "Libs.private: -lm\n"
  "Cflags: -I\$\{includedir\}\n")

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/wcslib.pc" DESTINATION lib/pkgconfig/)
