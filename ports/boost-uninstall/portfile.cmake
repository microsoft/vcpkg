set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

message(STATUS "\nPlease use the following command when you need to remove all boost ports/components:\n\
    \"./vcpkg remove boost-uninstall:${TARGET_TRIPLET} --recurse\"\n")

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/boost/vcpkg-cmake-wrapper.cmake" @ONLY)