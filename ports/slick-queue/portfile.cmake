vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-queue
    REF "v${VERSION}"
    SHA512 f68aefa611905e4f425741e7854caaed6746a4f9a8d9399ef6795881d62308acf758eaecc622ec6e34e942d5cd5a6ddf290975ccb42e0fb2889b1c576cc73559
    HEAD_REF main
    PATCHES
        slick-shm.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_QUEUE_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME slick-queue
    CONFIG_PATH lib/cmake/slick-queue
)

# Temporary fix for legacy package name compatibility
set(slick_queue_share "${CURRENT_PACKAGES_DIR}/share/slick_queue")
file(MAKE_DIRECTORY "${slick_queue_share}")

file(WRITE "${slick_queue_share}/slick_queueConfig.cmake" [=[
include("${CMAKE_CURRENT_LIST_DIR}/../slick-queue/slick-queueConfig.cmake")
]=])

file(COPY "${CURRENT_PACKAGES_DIR}/share/slick-queue/slick-queueConfigVersion.cmake"
     DESTINATION "${slick_queue_share}")
file(RENAME
     "${slick_queue_share}/slick-queueConfigVersion.cmake"
     "${slick_queue_share}/slick_queueConfigVersion.cmake")

# Header-only library - remove lib directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
