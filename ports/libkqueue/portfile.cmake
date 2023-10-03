vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mheily/libkqueue
    REF "v${VERSION}"
    SHA512 05703c89eb120c25ab5b42e85e632b71daeb36ba4379fbd5cebda853ac45a717c028251dd9ecda6444c10277d79fda395301898da41846675ba6f0f3c4a7e7d2
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/kqueue.dll ${CURRENT_PACKAGES_DIR}/bin/kqueue.dll)

    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/kqueue.dll ${CURRENT_PACKAGES_DIR}/debug/bin/kqueue.dll)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")