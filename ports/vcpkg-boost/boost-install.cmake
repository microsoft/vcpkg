include_guard(GLOBAL)

function(boost_configure_and_install)
  cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "SOURCE_PATH" "OPTIONS")

  string(REPLACE "-" "_" boost_lib_name "${PORT}")
  string(REPLACE "boost_" "" boost_lib_name "${boost_lib_name}")
  set(boost_lib_name_config "${boost_lib_name}")

  set(headers_only OFF)
  if(NOT EXISTS "${arg_SOURCE_PATH}/src" OR Z_VCPKG_BOOST_FORCE_HEADER_ONLY) # regex|system|math are header only and only install libs due to compat
    set(headers_only ON)
    set(VCPKG_BUILD_TYPE release)
  endif()

  set(boost_lib_path "libs/${boost_lib_name}")
  if(boost_lib_name MATCHES "numeric")
    string(REPLACE "numeric_" "numeric/" boost_lib_path "${boost_lib_path}")
    string(REPLACE "numeric_" "numeric/" boost_lib_name "${boost_lib_name}")
  elseif(PORT MATCHES "boost-(ublas|odeint|interval)")
    set(boost_lib_name_config "numeric_${boost_lib_name}")
    set(boost_lib_path "libs/numeric/${boost_lib_name}")
    set(boost_lib_name "numeric/${boost_lib_name}")
  endif()

  if(NOT EXISTS "${arg_SOURCE_PATH}/libs") # Check for --editable workflow
    set(target_path "${arg_SOURCE_PATH}/${boost_lib_path}")
    cmake_path(GET target_path PARENT_PATH parent_path)
    file(RENAME "${arg_SOURCE_PATH}/" "${arg_SOURCE_PATH}.tmp/")
    file(MAKE_DIRECTORY "${parent_path}")
    file(RENAME "${arg_SOURCE_PATH}.tmp/" "${target_path}")
  endif()

  # Beta builds contains a text in the version string
  string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" SEMVER_VERSION "${VERSION}")

  file(WRITE "${arg_SOURCE_PATH}/CMakeLists.txt" "\
cmake_minimum_required(VERSION 3.25)\n\
project(Boost VERSION ${SEMVER_VERSION} LANGUAGES CXX)\n\
set(BOOST_SUPERPROJECT_VERSION \${PROJECT_VERSION})\n\
set(BOOST_SUPERPROJECT_SOURCE_DIR \"\${PROJECT_SOURCE_DIR}\")\n\
list(APPEND CMAKE_MODULE_PATH \"${CURRENT_INSTALLED_DIR}/share/boost/cmake-build\")\n\
include(BoostRoot)\n"
  )

  if(PORT MATCHES "boost-(mpi|graph-parallel|property-map-parallel)")
    list(APPEND arg_OPTIONS -DBOOST_ENABLE_MPI=ON)
  endif()

  if(PORT MATCHES "boost-(python|parameter-python)")
    list(APPEND arg_OPTIONS -DBOOST_ENABLE_PYTHON=ON)
  endif()

  vcpkg_cmake_configure(
    SOURCE_PATH "${arg_SOURCE_PATH}"
    OPTIONS
      -DBOOST_INCLUDE_LIBRARIES=${boost_lib_name}
      -DBOOST_RUNTIME_LINK=${VCPKG_CRT_LINKAGE}
      "-DBOOST_INSTALL_INCLUDE_SUBDIR="
      "-DCMAKE_MSVC_DEBUG_INFORMATION_FORMAT="
      ${arg_OPTIONS}
  )

  vcpkg_cmake_install()

  file(GLOB cmake_paths "${CURRENT_PACKAGES_DIR}/lib/cmake/*" LIST_DIRECTORIES true)
  file(GLOB cmake_files "${CURRENT_PACKAGES_DIR}/lib/cmake/*" LIST_DIRECTORIES false)
  list(REMOVE_ITEM cmake_paths "${cmake_files}" "${CURRENT_PACKAGES_DIR}/lib/cmake/boost_${boost_lib_name_config}-${SEMVER_VERSION}")
  foreach(config_path IN LISTS cmake_paths)
    string(REPLACE "-${SEMVER_VERSION}" "" config_path "${config_path}")
    string(REPLACE "${CURRENT_PACKAGES_DIR}/lib/cmake/" "" config_name "${config_path}")
    vcpkg_cmake_config_fixup(PACKAGE_NAME ${config_name} CONFIG_PATH lib/cmake/${config_name}-${SEMVER_VERSION} DO_NOT_DELETE_PARENT_CONFIG_PATH)
  endforeach()

  if(PORT MATCHES "boost-(stacktrace|test)") 
    # These ports have no cmake config agreeing with the port name
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake" "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")
  else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME boost_${boost_lib_name_config} CONFIG_PATH lib/cmake/boost_${boost_lib_name_config}-${SEMVER_VERSION})
  endif()

  if(headers_only)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug/lib")
  endif()
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")
  vcpkg_install_copyright(FILE_LIST "${CURRENT_INSTALLED_DIR}/share/boost-cmake/copyright")

  # Install port specific usage
  set(BOOST_PORT_NAME "${boost_lib_name_config}")
  configure_file("${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost/usage.in" "${CURRENT_INSTALLED_DIR}/share/${PORT}/usage")
endfunction()
