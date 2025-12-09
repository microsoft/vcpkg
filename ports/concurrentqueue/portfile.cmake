set(VCPKG_BUILD_TYPE release)  # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/concurrentqueue
    REF v${VERSION}
    SHA512 a27306d1a7ad725daf5155a8e33a93efd29839708b2147ba703d036c4a92e04cbd8a505d804d2596ccb4dd797e88aca030b1cb34a4eaf09c45abb0ab55e604ea
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
