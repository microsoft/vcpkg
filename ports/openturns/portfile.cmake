vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openturns/openturns
    REF ad8482ece23d98802edc6258683e8353f9ff8b08
    SHA512 b0bc88bcf54945b5e786b480e640ee182926c75f1d871f70690d9609c98745b1907b3d9184c07586591fa45238c837da5a893a00d9c576a9e10232bcc9adc593
    HEAD_REF master
)

#vcpkg_find_acquire_program(PYTHON3)
#get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
#vcpkg_add_to_path("${PYTHON3_DIR}")
vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
vcpkg_add_to_path("${FLEX_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
vcpkg_add_to_path("${BISON_DIR}")

# option (USE_HMAT                     "Use HMat library"                                                      ON)
# option (USE_R                        "Use R for graph output support"                                        ON)
# option (USE_NLOPT                    "Use NLopt for additional optimization algorithms"                      ON)
# option (USE_CERES                    "Use Ceres Solver for additional optimization algorithms"               ON)
# option (USE_CMINPACK                 "Use CMinpack for additional optimization algorithms"                   ON)
# option (USE_DLIB                     "Use dlib for additional optimization algorithms"                       ON)
# option (USE_IPOPT                    "Use Ipopt for nonlinear optimization"                                  ON)
# option (USE_BONMIN                   "Use Bonmin for MINLP problems"                                         ON)
# option (USE_PAGMO                    "Use Pagmo for multi-objective optimization"                            ON)
# option (USE_SPECTRA                  "Use Spectra for eigenvalues computation"                               ON)
# option (USE_PRIMESIEVE               "Use primesieve for prime numbers generation"                           ON)
# option (USE_OPENMP                   "Use OpenMP to disable threading"                                       ON)
# option (USE_OPENBLAS                 "Use OpenBLAS to disable threading"                                     ON)
# option (BUILD_PYTHON                 "Build the python module for the library"                               ON)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      ${FEATURE_OPTIONS}
      -DBUILD_PYTHON:BOOL=ON
      -DUSE_BOOST:BOOL=ON # Required to make the distributions cross platform
      -DUSE_DOXYGEN:BOOL=OFF
      -DUSE_OPENMP:BOOL=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/OpenTURNSConfig.cmake" "/lib/cmake/" "/share/")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/OpenTURNSConfig.cmake" "/lib" "$<$<CONFIG:DEBUG>:/debug>/lib")


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/pthread.h"
            "${CURRENT_PACKAGES_DIR}/include/semaphore.h"
            "${CURRENT_PACKAGES_DIR}/include/unistd.h")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")
