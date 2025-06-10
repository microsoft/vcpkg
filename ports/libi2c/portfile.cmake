vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO busytester/libi2c
    REF bbd8c785b2729681a8b8e81af904a80da3e5aa9b
    SHA512 d3dcd7a1f0d3d3a33263901e98a614984a8e2ddbc0df37db12dc6d94cadd7434ca103be9a93cb68233361097daf1c7ac4912da6b26ec21ebdf92a706ee684492
)

vcpkg_execute_required_process(
    COMMAND make libi2cio.so
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME build-${TARGET_TRIPLET}
)

message(STATUS "Contents of ${SOURCE_PATH}:")
file(GLOB SOURCE_FILES "${SOURCE_PATH}/*")
foreach(FILE ${SOURCE_FILES})
    message(STATUS "${FILE}")
endforeach()

message(STATUS "Contents of ${SOURCE_PATH}/Makefile:")
file(READ "${SOURCE_PATH}/Makefile" MAKEFILE_CONTENTS)
message(STATUS "${MAKEFILE_CONTENTS}")

# Debug: Print contents of BUILD_DIR after build
message(STATUS "Contents of ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel:")
file(GLOB_RECURSE BUILD_FILES "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*")
foreach(FILE ${BUILD_FILES})
    message(STATUS "${FILE}")
endforeach()

# Debug: Print contents of BUILD_DIR after build
message(STATUS "Contents of ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel after build:")
file(GLOB_RECURSE BUILD_FILES "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*")
foreach(FILE ${BUILD_FILES})
    message(STATUS "${FILE}")
endforeach()

# Install
if(EXISTS "${SOURCE_PATH}/libi2cio.so")
    file(INSTALL "${SOURCE_PATH}/libi2cio.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(INSTALL "${SOURCE_PATH}/libi2cio.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
else()
    message(FATAL_ERROR "libi2cio.so not found in ${SOURCE_PATH}")
endif()

if(EXISTS "${SOURCE_PATH}/i2c-io.h")
    file(INSTALL "${SOURCE_PATH}/i2c-io.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
else()
    message(FATAL_ERROR "i2c-io.h not found in ${SOURCE_PATH}")
endif()

vcpkg_copy_pdbs()
