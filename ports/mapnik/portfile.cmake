set(MAPNIK_VERSION 3.0.22)
include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/am2222/mapnik-windows.git")
set(GIT_REV "fdba45cd95b66576e47de2e56d30196bfc9de99d")

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT})

if(NOT EXISTS "${SOURCE_PATH}/.git")
	message(STATUS "Cloning and fetching submodules")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} clone --recurse-submodules ${GIT_URL} ${SOURCE_PATH}
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME clone
	)

	message(STATUS "Checkout revision ${GIT_REV}")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} checkout ${GIT_REV}
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME checkout
	)
endif()
message(STATUS "Adding worktree done")


vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON2_DIR}")

set(BOOST_ROOT ${CURRENT_INSTALLED_DIR})

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(MAPNIK_STATIC_LIB OFF)
elseif (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  set(MAPNIK_STATIC_LIB ON)
endif()



if ("zlib" IN_LIST FEATURES)
  set(CMAKE_DISABLE_FIND_PACKAGE_ZLIB OFF)
else()
  set(CMAKE_DISABLE_FIND_PACKAGE_ZLIB ON)
endif()




vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mapnik
 #    PREFER_NINJA # Disable this option if project cannot be built with Ninja
#    NO_CHARSET_FLAG # automatic templates
    OPTIONS 
      -DMAPNIK_STATIC_LIB=${MAPNIK_STATIC_LIB}
      -DBOOST_PREFIX=${CURRENT_INSTALLED_DIR}/include
      -DFREE_TYPE_INCLUDE=${CURRENT_INSTALLED_DIR}/include/freetype2
)

vcpkg_install_cmake()



file(COPY ${SOURCE_PATH}/include/mapnik DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()
file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
if(EXES)
    file(COPY ${EXES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik)
    file(REMOVE ${EXES})
endif()

file(GLOB EXES "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
if(EXES)
    file(REMOVE ${EXES})
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/mapnik)

file(COPY ${SOURCE_PATH}/demo/data DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik/demo)
file(COPY ${SOURCE_PATH}/fonts DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik)
file(COPY ${CURRENT_PACKAGES_DIR}/bin/plugins DESTINATION ${CURRENT_PACKAGES_DIR}/tools/mapnik)
#file(REMOVE_RECURSE  "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mapnik RENAME copyright)
file(INSTALL ${SOURCE_PATH}/fonts/unifont_license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/mapnik RENAME fonts_copyright)