set(VERSION_MAJOR 3)
set(VERSION_MINOR 6)
set(VERSION_PATCH 5)
set(VERSION_FULL ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
set(BSONCXX_STANDARD 11)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-cxx-driver
    REF r${VERSION_FULL}
    SHA512 fe304d2f406f65d79a030dcfd1509543a9ab3057e46328d5ca1fc58da04758b9a2c6666a6194d574f9b42022324972d41c37d00d6fba87dfba63fbfb99e821de
    HEAD_REF master
    PATCHES
        fix-uwp.patch
        disable-c2338-mongo-cxx-driver.patch
        disable_test_and_example.patch
        github-654.patch
        fix-dependencies.patch
)

if ("mnmlstc" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_WINDOWS)
        message(FATAL_ERROR "Feature mnmlstc only supports UNIX")
    endif()
    set(BSONCXX_POLY MNMLSTC)
elseif ("system-mnmlstc" IN_LIST FEATURES)
    message("Please make sure you have mnmlstc installed via the package manager")
    set(BSONCXX_POLY SYSTEM_MNMLSTC)
elseif ("boost" IN_LIST FEATURES)
    set(BSONCXX_POLY BOOST)
elseif("std-experimental" IN_LIST FEATURES)
    set(BSONCXX_POLY STD_EXPERIMENTAL)
    set(BSONCXX_STANDARD 17)
else()
  if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(BSONCXX_POLY BOOST)
  else()
    set(BSONCXX_POLY MNMLSTC)
  endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMONGOCXX_HEADER_INSTALL_DIR=include
        -DBSONCXX_HEADER_INSTALL_DIR=include
        -DBSONCXX_POLY_USE_${BSONCXX_POLY}=1
        -DCMAKE_CXX_STANDARD=${BSONCXX_STANDARD}
        -DBUILD_VERSION=${VERSION_FULL}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME bsoncxx CONFIG_PATH "lib/cmake/bsoncxx-${VERSION_FULL}" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME mongocxx CONFIG_PATH "lib/cmake/mongocxx-${VERSION_FULL}")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/libbsoncxx/libbsoncxx-config.cmake"
"
message(WARNING \"This CMake target is deprecated.  Use mongo::bsoncxx instead.\")

set(LIBBSONCXX_VERSION_MAJOR ${VERSION_MAJOR})
set(LIBBSONCXX_VERSION_MINOR ${VERSION_MINOR})
set(LIBBSONCXX_VERSION_PATCH ${VERSION_PATCH})
set(LIBBSONCXX_PACKAGE_VERSION ${VERSION_FULL})

include(CMakeFindDependencyMacro)
find_dependency(bsoncxx CONFIG REQUIRED)
get_filename_component(LIBBSONCXX_INCLUDE_DIRS \"\${CMAKE_CURRENT_LIST_DIR}/../../include\" ABSOLUTE)
if (TARGET mongo::bsoncxx_shared)
    set(LIBBSONCXX_LIBRARIES mongo::bsoncxx_shared)
else()
    set(LIBBSONCXX_LIBRARIES mongo::bsoncxx_static)
endif()
"
)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libmongocxx/libmongocxx-config.cmake
"
message(WARNING \"This CMake target is deprecated.  Use mongo::mongocxx instead.\")

set(LIBMONGOCXX_VERSION_MAJOR ${VERSION_MAJOR})
set(LIBMONGOCXX_VERSION_MINOR ${VERSION_MINOR})
set(LIBMONGOCXX_VERSION_PATCH ${VERSION_PATCH})
set(LIBMONGOCXX_PACKAGE_VERSION ${VERSION_FULL})

include(CMakeFindDependencyMacro)
find_dependency(mongocxx CONFIG REQUIRED)
get_filename_component(LIBMONGOCXX_INCLUDE_DIRS \"\${CMAKE_CURRENT_LIST_DIR}/../../include\" ABSOLUTE)
if (TARGET mongo::bsoncxx_shared)
    set(LIBMONGOCXX_LIBRARIES mongo::mongocxx_shared)
else()
    set(LIBMONGOCXX_LIBRARIES mongo::mongocxx_static)
endif()
"
)

vcpkg_fixup_pkgconfig()

if (NOT BSONCXX_POLY STREQUAL MNMLSTC)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/bsoncxx/third_party")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
)
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/${PORT}/uninstall.sh")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(COPY "${SOURCE_PATH}/THIRD-PARTY-NOTICES" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
