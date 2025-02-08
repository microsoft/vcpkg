vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.xiph.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/icecast-libshout
    REF "v${VERSION}"
    HEAD_REF master
    SHA512 04dbb567f36269506becc3a50eb5fa263cbc308764c3fc1e59c3ab4833ef944479d0d35af33941214ff86899c40253a0ded095e5e217035848ce2694496720b5
)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.xiph.org
    OUT_SOURCE_PATH SOURCE_PATH_COMMON
    REPO xiph/icecast-common
    REF 5de3e8b3b063002d8a9f52122e97f721e1742531
    HEAD_REF master
    SHA512 eb505b9019a97a91e10fa505225dde4f9950f6ae50b54c7afd806f6eebeb865862de85e9d0a114f2e8c4f974c4db60622e71f52f5e758cdb0efcda735bb7ab51
)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.xiph.org
    OUT_SOURCE_PATH SOURCE_PATH_M4
    REPO xiph/icecast-m4
    REF 57027c6cc3f8b26d59e9560b4ac72a1a06d643b9
    HEAD_REF master
    SHA512 d2a9507a5a0d36134c4dc37fe38b3cb4d954dee3ffa5fd2b1bb4cd8af1e7804248e234e55fbcfba20fecec4bf159b2616d14ac537d03ffbff095a02d5f4bf201
)

file(COPY ${SOURCE_PATH_COMMON}/ DESTINATION ${SOURCE_PATH}/src/common)
file(COPY ${SOURCE_PATH_M4}/ DESTINATION ${SOURCE_PATH}/m4)

set(FEATURE_OPTIONS "")
if(NOT "speex" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "--disable-speex")
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
