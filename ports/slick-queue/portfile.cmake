vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-queue
    REF "v${VERSION}"
    SHA512 7a6a10ff5651c956a826e89ee6f92ee92b3bc7d3c20603f6f76ab8e2ca0150ae1db2a269692e6426470e147d61be3ea53bddeeca6b999ab0191807019eda9945
    HEAD_REF main
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
