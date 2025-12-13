vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TileDB-Inc/TileDB
    REF "${VERSION}"
    HEAD_REF main
    SHA512 fdf8b41ec3b412874dbed4d8420a95821accf31a627f0746ca81656a98e60326aa479ffe7c8561b11c6fd7bc78dcaa8e9750bb2fcc94f92319c73379160caed9
    PATCHES
        rm-cpp17-pmr.patch
)

file(REMOVE_RECURSE
    "${SOURCE_PATH}/external/"
    "${SOURCE_PATH}/tiledb/common/polymorphic_allocator/"
    "${SOURCE_PATH}/tiledb/sm/serialization/tiledb-rest.capnp.c++"
    "${SOURCE_PATH}/tiledb/sm/serialization/tiledb-rest.capnp.h"
)

if ("serialization" IN_LIST FEATURES)
    # Regenerate the capnp serialization files with the version installed in vcpkg.
    # This allows updating capnproto independently of upstream tiledb.

    # Add capnproto directory to PATH, in order to find the C++ plugin.
    vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/capnproto")
    vcpkg_execute_required_process(
        COMMAND
            "${CURRENT_HOST_INSTALLED_DIR}/tools/capnproto/capnp${VCPKG_HOST_EXECUTABLE_SUFFIX}"
            "compile"
            "-I${CURRENT_HOST_INSTALLED_DIR}/include"
            "-oc++:${SOURCE_PATH}/tiledb/sm/serialization"
            "${SOURCE_PATH}/tiledb/sm/serialization/tiledb-rest.capnp"
            "--src-prefix=${SOURCE_PATH}/tiledb/sm/serialization"
        WORKING_DIRECTORY "${CURRENT_HOST_INSTALLED_DIR}/tools/capnproto"
        LOGNAME gen-capnp-sources
    )
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        azure TILEDB_AZURE
        gcs TILEDB_GCS
        s3 TILEDB_S3
        serialization TILEDB_SERIALIZATION
        webp TILEDB_WEBP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTILEDB_TESTS=OFF
        -DTILEDB_TOOLS=OFF
        -DTILEDB_CPP_API=ON
        -DTILEDB_STATS=ON
        -DTILEDB_WERROR=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        # Suppress auto-detecting AVX2 support, because it makes builds non-deterministic.
        # Anybody who wants it has to explicitly enable it in a triplet.
        -DCOMPILER_SUPPORTS_AVX2=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TileDB)

file(REMOVE_RECURSE
    # pkgconfig files are currently broken.
    "${CURRENT_PACKAGES_DIR}/lib/pkgconfig"
    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig"
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
