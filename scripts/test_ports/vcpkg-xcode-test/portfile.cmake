set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

set(working_directory "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
if (EXISTS "${working_directory}")
    file(REMOVE_RECURSE "${working_directory}")
endif()
file(MAKE_DIRECTORY "${working_directory}")

vcpkg_execute_required_process(
    COMMAND "${CMAKE_COMMAND}" -G Xcode "${CMAKE_CURRENT_LIST_DIR}/project/CMakeLists.txt" "-DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}"
    WORKING_DIRECTORY "${working_directory}"
    LOGNAME "${PORT}-config"
)

vcpkg_xcode_install(
    SOURCE_PATH "${working_directory}"
    PROJECT_FILE "xcode-test.xcodeproj"
)

if (NOT EXISTS "${CURRENT_PACKAGES_DIR}/lib/libxcode-test.a")
    message(FATAL_ERROR "vcpkg-xcode install binary failed!")
endif()

if (NOT EXISTS "${CURRENT_PACKAGES_DIR}/include/xcode-test.h")
    message(FATAL_ERROR "vcpkg-xcode install header failed!")
endif()
