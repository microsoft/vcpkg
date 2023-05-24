set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ARROW_LINK_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${CURRENT_INSTALLED_DIR}/share/arrow/example"
    OPTIONS
        -DARROW_LINK_SHARED=${ARROW_LINK_SHARED}
)
vcpkg_cmake_build()
