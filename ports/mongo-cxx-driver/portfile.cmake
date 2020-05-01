set(VERSION_MAJOR 3)
set(VERSION_MINOR 4)
set(VERSION_PATCH 0)
set(VERSION_FULL ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-cxx-driver
    REF r${VERSION_FULL}
    SHA512 28c052904f1b456b92482097166238eae1ad50c3ed207496f09366b46f2c9465c7e98c7219f4f10314e4d8fdd01c36b70a2221891bb75231adcc1edf013d43ce
    HEAD_REF master
    PATCHES
        fix-uwp.patch
        disable-c2338-mongo-cxx-driver.patch
        disable_test_and_example.patch
)

if ("mnmlstc" IN_LIST FEATURES)
    set(BSONCXX_POLY MNMLSTC)
elseif ("system-mnmlstc" IN_LIST FEATURES)
    set(BSONCXX_POLY SYSTEM_MNMLSTC)
elseif ("boost" IN_LIST FEATURES)
    set(BSONCXX_POLY BOOST)
elseif("std-experimental" IN_LIST FEATURES)
    set(BSONCXX_POLY STD_EXPERIMENTAL)
else()
  if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(BSONCXX_POLY BOOST)
  else()
    set(BSONCXX_POLY MNMLSTC)
  endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLIBBSON_DIR=${CURRENT_INSTALLED_DIR}
        -DLIBMONGOC_DIR=${CURRENT_INSTALLED_DIR}
        -DMONGOCXX_HEADER_INSTALL_DIR=include
        -DBSONCXX_HEADER_INSTALL_DIR=include
        -DBSONCXX_POLY_USE_${BSONCXX_POLY}=1
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(WRITE ${CURRENT_PACKAGES_DIR}/share/libbsoncxx/libbsoncxx-config.cmake
"
set(LIBBSONCXX_VERSION_MAJOR ${VERSION_MAJOR})
set(LIBBSONCXX_VERSION_MINOR ${VERSION_MINOR})
set(LIBBSONCXX_VERSION_PATCH ${VERSION_PATCH})
set(LIBBSONCXX_PACKAGE_VERSION ${VERSION_FULL})

get_filename_component(PACKAGE_PREFIX_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../\" ABSOLUTE)

set(LIBBSONCXX_INCLUDE_DIRS \"\${PACKAGE_PREFIX_DIR}/include\")
find_library(LIBBSONCXX_LIBRARY_PATH_RELEASE bsoncxx bsoncxx-static PATHS \"\${PACKAGE_PREFIX_DIR}/lib\" NO_DEFAULT_PATH)
find_library(LIBBSONCXX_LIBRARY_PATH_DEBUG bsoncxx bsoncxx-static PATHS \"\${PACKAGE_PREFIX_DIR}/debug/lib\" NO_DEFAULT_PATH)
set(LIBBSONCXX_LIBRARIES optimized \${LIBBSONCXX_LIBRARY_PATH_RELEASE} debug \${LIBBSONCXX_LIBRARY_PATH_DEBUG})
"
)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libmongocxx/libmongocxx-config.cmake
"
set(LIBMONGOCXX_VERSION_MAJOR ${VERSION_MAJOR})
set(LIBMONGOCXX_VERSION_MINOR ${VERSION_MINOR})
set(LIBMONGOCXX_VERSION_PATCH ${VERSION_PATCH})
set(LIBMONGOCXX_PACKAGE_VERSION ${VERSION_FULL})

include(CMakeFindDependencyMacro)

find_dependency(libbsoncxx)

get_filename_component(PACKAGE_PREFIX_DIR \"\${CMAKE_CURRENT_LIST_DIR}/../../\" ABSOLUTE)

set(LIBMONGOCXX_INCLUDE_DIRS \"\${PACKAGE_PREFIX_DIR}/include\" \${LIBBSONCXX_INCLUDE_DIRS})
find_library(LIBMONGOCXX_LIBRARY_PATH_RELEASE NAMES mongocxx mongocxx-static PATHS \"\${PACKAGE_PREFIX_DIR}/lib\" NO_DEFAULT_PATH)
find_library(LIBMONGOCXX_LIBRARY_PATH_DEBUG NAMES mongocxx mongocxx-static PATHS \"\${PACKAGE_PREFIX_DIR}/debug/lib\" NO_DEFAULT_PATH)
set(LIBMONGOCXX_LIBRARIES optimized \${LIBMONGOCXX_LIBRARY_PATH_RELEASE} debug \${LIBMONGOCXX_LIBRARY_PATH_DEBUG} \${LIBBSONCXX_LIBRARIES})
"
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

if (NOT BSONCXX_POLY STREQUAL MNMLSTC)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/bsoncxx/third_party)
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/include/bsoncxx/cmake
    ${CURRENT_PACKAGES_DIR}/include/bsoncxx/config/private
    ${CURRENT_PACKAGES_DIR}/include/bsoncxx/private
    ${CURRENT_PACKAGES_DIR}/include/bsoncxx/test
    ${CURRENT_PACKAGES_DIR}/include/bsoncxx/test_util

    ${CURRENT_PACKAGES_DIR}/include/mongocxx/cmake
    ${CURRENT_PACKAGES_DIR}/include/mongocxx/config/private
    ${CURRENT_PACKAGES_DIR}/include/mongocxx/exception/private
    ${CURRENT_PACKAGES_DIR}/include/mongocxx/options/private
    ${CURRENT_PACKAGES_DIR}/include/mongocxx/gridfs/private
    ${CURRENT_PACKAGES_DIR}/include/mongocxx/private
    ${CURRENT_PACKAGES_DIR}/include/mongocxx/test
    ${CURRENT_PACKAGES_DIR}/include/mongocxx/test_util

    ${CURRENT_PACKAGES_DIR}/debug/include
)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(COPY ${SOURCE_PATH}/THIRD-PARTY-NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
