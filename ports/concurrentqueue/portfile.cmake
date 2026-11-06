set(VCPKG_BUILD_TYPE release)  # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/concurrentqueue
    REF v${VERSION}
    SHA512 7a58f237a38b3faed778fbe8508eadd9e5b282bd38ef4a0f40118498cf578fe96f1d4272c0b839bd290150e6ff25c6d44fe7362e3fc046b04d44ade8edd091ea
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/concurrentqueue")

# transitional polyfill
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/concurrentqueue/unofficial/concurrentqueue")
file(WRITE "${CURRENT_PACKAGES_DIR}/include/concurrentqueue/unofficial/concurrentqueue/concurrentqueue.h" [[#include "../../moodycamel/concurrentqueue.h"]])
file(COPY "${CURRENT_PORT_DIR}/unofficial-concurrentqueue-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-concurrentqueue")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(RENAME "${CURRENT_PACKAGES_DIR}/include/concurrentqueue/moodycamel/LICENSE.md" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
