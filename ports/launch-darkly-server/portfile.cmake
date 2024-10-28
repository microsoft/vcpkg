vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO launchdarkly/c-server-sdk
    REF a79f743bda933af3c45ab6ca5c6448df4b815667 # 2.8.6
    SHA512 5f5982def5d2e9272751f35cbc0891ef967ae189d56da996e00410205ab0d57c196b66f7be0ba918ee6f82a584e5d75257e77f03c9b644c3174c35ea015802f7 
    HEAD_REF master
    PATCHES
        findPCRE.patch
        FixStrictPrototypes.patch # required with clang-15
        removeWarningAsError.patch
        fix-depend-clib.patch
)


vcpkg_from_github(
    OUT_SOURCE_PATH HEXIFY_SOURCE_DIR
    REPO pepaslabs/hexify.c
    REF f823bd619f73584a75829cc1e44a532f5e09336e
    SHA512 fdfd3877874cb5b3e506d791c08840b156ba6905cee520adc225755f7ca768e54a2efa4d05cbef72d275ca2596e1a4d8e4fbb254f9cc4188c31a41b9904479bc
    HEAD_REF master
    PATCHES
        ${SOURCE_PATH}/patches/hexify.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SEMVER_SOURCE_DIR
    REPO h2non/semver.c
    REF bd1db234a68f305ed10268bd023df1ad672061d7
    SHA512 29c7ab45e6550977bb6c74ebddfff440559a6e6494b701fc69a815912e6d683e5f4b4dfe17c98a892e8a82766f33c83edbe11e973579bd1d2175384cbaadd731
    HEAD_REF master
    PATCHES 
        ${SOURCE_PATH}/patches/semver.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SHA1_SOURCE_DIR
    REPO clibs/sha1
    REF fa1d96ec293d2968791603548125e3274bd6b472
    SHA512 fd7dfbed4ac10e2c482da1cd460dabf0a53965e6fa17fab97156becb8214e435ee3605b2748705141380e254de7c32ab42da5e42cd6e4494f7ecaafb3b9e19f0
    HEAD_REF master
    PATCHES
        fix-confilct-with-openssl.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH TIMESTAMP_SOURCE_DIR
    REPO chansen/c-timestamp
    REF b205c407ae6680d23d74359ac00444b80989792f
    SHA512 497a1766b58e6e1c5ff2edf4fd6ff5f1065c4bdac60767988a5da03f93b0724ef582240aa015f3ab724200c249fe98072c67efbfc90e54d986a42212b43030ea
    HEAD_REF master
    PATCHES 
        ${SOURCE_PATH}/patches/timestamp.patch
)

vcpkg_download_distfile(UTHASH_COMPRESSED_FILE
    URLS https://github.com/troydhanson/uthash/archive/v2.3.0.tar.gz
    FILENAME uthash-archive-v2.3.0.tar.gz
    SHA512 3b01f1074790fb242900411cb16eb82c1a9afcf58e3196a0f4611d9d7ef94690ad38c0a500e7783d3efa20328aa8d6ab14f246be63b3b3d385502ba2b6b2a294
)
vcpkg_extract_source_archive(UTHASH_SOURCE_DIR
    ARCHIVE ${UTHASH_COMPRESSED_FILE}
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DFETCHCONTENT_SOURCE_DIR_HEXIFY=${HEXIFY_SOURCE_DIR}
        -DFETCHCONTENT_SOURCE_DIR_SEMVER=${SEMVER_SOURCE_DIR}
        -DFETCHCONTENT_SOURCE_DIR_SHA1=${SHA1_SOURCE_DIR}
        -DFETCHCONTENT_SOURCE_DIR_TIMESTAMP=${TIMESTAMP_SOURCE_DIR}
        -DFETCHCONTENT_SOURCE_DIR_UTHASH=${UTHASH_SOURCE_DIR}
        -DSKIP_DATABASE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
	CONFIG_PATH lib/cmake/ldserverapi
)

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
)
    
vcpkg_copy_pdbs()

set(shareDir "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY ${CMAKE_CURRENT_LIST_DIR}/launch-darkly-server-config.cmake DESTINATION ${shareDir})
file(RENAME ${shareDir}/ldserverapiTargets.cmake ${shareDir}/ldserverapi-targets.cmake)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
