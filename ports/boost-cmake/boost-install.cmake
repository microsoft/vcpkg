include_guard(GLOBAL)

function(boost_configure_and_install)
  cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "SOURCE_PATH" "OPTIONS")

  string(REPLACE "-" "_" boost_lib_name "${PORT}")
  string(REPLACE "boost_" "" boost_lib_name "${boost_lib_name}")
  set(boost_lib_name_config "${boost_lib_name}")

  set(headers_only OFF)
  if(NOT EXISTS "${arg_SOURCE_PATH}/src")
    set(headers_only ON)
  endif()

  set(boost_lib_path "libs/${boost_lib_name}")
  if(boost_lib_name MATCHES "numeric")
    string(REPLACE "numeric_" "numeric/" boost_lib_path "${boost_lib_path}")
    string(REPLACE "numeric_" "numeric/" boost_lib_name "${boost_lib_name}")
  endif()

  if(NOT EXISTS "${arg_SOURCE_PATH}/libs") # Check for --editable workflow
    set(target_path "${arg_SOURCE_PATH}/${boost_lib_path}")
    cmake_path(GET target_path PARENT_PATH parent_path)
    file(RENAME "${arg_SOURCE_PATH}/" "${arg_SOURCE_PATH}.tmp/")
    file(MAKE_DIRECTORY "${parent_path}")
    file(RENAME "${arg_SOURCE_PATH}.tmp/" "${target_path}")
  endif()

  file(WRITE "${arg_SOURCE_PATH}/CMakeLists.txt" " \
  cmake_minimum_required(VERSION 3.25) \n\
 \n\
  project(Boost VERSION ${VERSION} LANGUAGES CXX) \n\
 \n\
  set(BOOST_SUPERPROJECT_VERSION \${PROJECT_VERSION}) \n\
  set(BOOST_SUPERPROJECT_SOURCE_DIR \"\${PROJECT_SOURCE_DIR}\") \n\
 \n\
  list(APPEND CMAKE_MODULE_PATH \"${CURRENT_INSTALLED_DIR}/share/boost/cmake-build\") \n\
 \n\
  include(BoostRoot) \n\
  ")
  vcpkg_cmake_configure(
    SOURCE_PATH "${arg_SOURCE_PATH}"
    OPTIONS
      -DBOOST_INCLUDE_LIBRARIES=${boost_lib_name}
      #"-DBOOST_INSTALL_CMAKEDIR=lib/cmake"
      "-DBOOST_INSTALL_INCLUDE_SUBDIR="
      ${arg_OPTIONS}
  )

  vcpkg_cmake_install()

  vcpkg_cmake_config_fixup(PACKAGE_NAME boost_${boost_lib_name_config} CONFIG_PATH lib/cmake/boost_${boost_lib_name_config}-${VERSION})

  if(headers_only OR "${PORT}" STREQUAL "boost-system") # TODO fix boost-system
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug/lib")
  endif()
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
  if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    #file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
  endif()
  vcpkg_install_copyright(FILE_LIST "${CURRENT_INSTALLED_DIR}/share/boost-cmake/copyright")
endfunction()

#BOOST_ENABLE_MPI
#BOOST_ENABLE_PYTHON
#BOOST_RUNTIME_LINK
#BOOST_STAGEDIR
#BOOST_INCLUDE_LIBRARIES can be set to the respective lib name
#BOOST_SUPERPROJECT_SOURCE_DIR