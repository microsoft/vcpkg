set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

set(FUNCTION_NAME x_vcpkg_find_fortran)

if(VCPKG_CROSSCOMPILING)
    # make FATAL_ERROR in CI when issue #16773 fixed
    # message(WARNING "${PORT} is a host-only port; please mark it as a host port in your dependencies.")
    # NOTE: Interessting case here: Would need to go from target --> host --> target. 
endif()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/${FUNCTION_NAME}.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

configure_file("${VCPKG_ROOT_DIR}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-port-config.cmake" @ONLY)

find_library(PGMATH NAMES libpgmath pgmath PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATHS)
cmake_path(GET PGMATH FILENAME pgmathlibname)
find_library(flanglib NAMES libflang flang PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATHS)
cmake_path(GET flanglib FILENAME flanglibname)
find_library(flangrtilib NAMES libflangrti flangrti PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATHS)
cmake_path(GET flangrtilib FILENAME flangrtilibname)
if(VCPKG_OPENMP)
    find_library(omplib NAMES libomp omp PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATHS)
    cmake_path(GET omplib FILENAME omplibname)
else()
    find_library(omplib NAMES libompstub ompstub PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATHS)
    cmake_path(GET omplib FILENAME omplibname)
endif()
find_library(flangmainlib NAMES libflangmain flangmain PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATHS)
cmake_path(GET flangmainlib FILENAME flangmainlibname)

vcpkg_list(SET flang_compile_libs "")
vcpkg_list(SET libs "-l${flanglibname} -l${flangrtilibname} -l${pgmathlibname} -l${omplibname}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-fortran-flang-classic.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/vcpkg-fortran-flang-classic.pc" @ONLY)
if(NOT VCPKG_BUILD_TYPE)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-fortran-flang-classic.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/vcpkg-fortran-flang-classic.pc" @ONLY)
endif()
