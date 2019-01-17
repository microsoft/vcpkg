include(vcpkg_common_functions)
vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
    REPO mongodb/mongo-cxx-driver
	REF r3.2.0
    SHA512 cad8dd6e9fd75aa3aee15321c9b3df21d43c346f5b0b3dd75c86f9117d3376ad83fcda0c4a333c0a23d555e76d79432016623dd5f860ffef9964a6e8046e84b5
	HEAD_REF master
	PATCHES
	 "${CURRENT_PORT_DIR}/disable_test_and_example.patch"
	 "${CURRENT_PORT_DIR}/fix-uwp.patch"
	 "${CURRENT_PORT_DIR}/disable-c2338-mongo-cxx-driver.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DLIBBSON_DIR=${CURRENT_INSTALLED_DIR}
        -DLIBMONGOC_DIR=${CURRENT_INSTALLED_DIR}
)

vcpkg_install_cmake()

#move the cmake files for bsoncxx as the fixup below will delete them
file(RENAME
    ${CURRENT_PACKAGES_DIR}/lib/cmake/libbsoncxx-3.2.0
    ${CURRENT_PACKAGES_DIR}/temp)

#fixup files in the normal way for the main driver package (unsure how to avoid using the version number here)
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/libmongocxx-3.2.0")

#restore the files for bsoncxx into the new share path fixup created
file(RENAME
    ${CURRENT_PACKAGES_DIR}/temp
    ${CURRENT_PACKAGES_DIR}/share/libbsoncxx)

#patch include directories, as we do with libbson and mongo-c-driver
file(READ ${CURRENT_PACKAGES_DIR}/share/mongo-cxx-driver/libmongocxx-config.cmake LIBMONGOCXX_CONFIG_CMAKE)
string(REPLACE "/include/mongocxx/v_noabi" "/include/mongocxx" LIBMONGOCXX_CONFIG_CMAKE "${LIBMONGOCXX_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/mongo-cxx-driver/libmongocxx-config.cmake "${LIBMONGOCXX_CONFIG_CMAKE}")

file(READ ${CURRENT_PACKAGES_DIR}/share/libbsoncxx/libbsoncxx-config.cmake LIBBSONCXX_CONFIG_CMAKE)
string(REPLACE "/../../.." "/../.." LIBBSONCXX_CONFIG_CMAKE "${LIBBSONCXX_CONFIG_CMAKE}")
string(REPLACE "/include/bsoncxx/v_noabi" "/include/bsoncxx" LIBBSONCXX_CONFIG_CMAKE "${LIBBSONCXX_CONFIG_CMAKE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libbsoncxx/libbsoncxx-config.cmake "${LIBBSONCXX_CONFIG_CMAKE}")

#rename the main driver files to match the package name in vcpkg
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mongo-cxx-driver/libmongocxx-config.cmake ${CURRENT_PACKAGES_DIR}/share/mongo-cxx-driver/mongo-cxx-driver-config.cmake)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mongo-cxx-driver/libmongocxx-config-version.cmake ${CURRENT_PACKAGES_DIR}/share/mongo-cxx-driver/mongo-cxx-driver-config-version.cmake)

file(RENAME
    ${CURRENT_PACKAGES_DIR}/include/bsoncxx/v_noabi/bsoncxx
    ${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/bsoncxx)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include/bsoncxx)

file(RENAME
    ${CURRENT_PACKAGES_DIR}/include/mongocxx/v_noabi/mongocxx
    ${CURRENT_PACKAGES_DIR}/temp)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/mongocxx)
file(RENAME ${CURRENT_PACKAGES_DIR}/temp ${CURRENT_PACKAGES_DIR}/include/mongocxx)

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

    ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/bsoncxx.lib)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/bsoncxx.lib)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/mongocxx.lib)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/mongocxx.lib)

    file(RENAME
        ${CURRENT_PACKAGES_DIR}/lib/libbsoncxx.lib
        ${CURRENT_PACKAGES_DIR}/lib/bsoncxx.lib)
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/debug/lib/libmongocxx.lib
        ${CURRENT_PACKAGES_DIR}/debug/lib/mongocxx.lib)

    # define MONGOCXX_STATIC in config/export.hpp
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/static.patch
    )
else()
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/libbsoncxx.lib)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/libbsoncxx.lib)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/lib/libmongocxx.lib)
    file(REMOVE         ${CURRENT_PACKAGES_DIR}/debug/lib/libmongocxx.lib)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-cxx-driver RENAME copyright)
file(COPY ${SOURCE_PATH}/THIRD-PARTY-NOTICES DESTINATION ${CURRENT_PACKAGES_DIR}/share/mongo-cxx-driver)

vcpkg_copy_pdbs()