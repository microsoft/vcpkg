include(vcpkg_common_functions)

set(VERSION_MAJOR 3)
set(VERSION_MINOR 2)
set(VERSION_PATCH 0)
set(VERSION_FULL ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-cxx-driver
    REF r${VERSION_FULL}
    SHA512 cad8dd6e9fd75aa3aee15321c9b3df21d43c346f5b0b3dd75c86f9117d3376ad83fcda0c4a333c0a23d555e76d79432016623dd5f860ffef9964a6e8046e84b5
    HEAD_REF master
    PATCHES
        disable_test_and_example.patch
        fix-uwp.patch
        disable-c2338-mongo-cxx-driver.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DLIBBSON_DIR=${CURRENT_INSTALLED_DIR}
        -DLIBMONGOC_DIR=${CURRENT_INSTALLED_DIR}
        -DMONGOCXX_HEADER_INSTALL_DIR=include
        -DBSONCXX_HEADER_INSTALL_DIR=include
)

vcpkg_install_cmake()

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

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/include/bsoncxx/cmake
    ${CURRENT_PACKAGES_DIR}/include/bsoncxx/config/private
    ${CURRENT_PACKAGES_DIR}/include/bsoncxx/private
    ${CURRENT_PACKAGES_DIR}/include/bsoncxx/test
    ${CURRENT_PACKAGES_DIR}/include/bsoncxx/test_util
    ${CURRENT_PACKAGES_DIR}/include/bsoncxx/third_party

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

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-cxx-driver RENAME copyright)
file(COPY ${SOURCE_PATH}/THIRD-PARTY-NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-cxx-driver)

vcpkg_copy_pdbs()
