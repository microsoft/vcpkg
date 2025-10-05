vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deadlightreal/SwiftNet
    REF 1.0.0
    SHA512 fcccf5509cd97bef076b2ce3bb95b1c1c029935d00597e5281415878b61e6c4c2da8471292e986bf6f324e21bd9b9efef5908cf96897ff8981293a71cb6cee5a
)

file(MAKE_DIRECTORY ${SOURCE_PATH}/build)

vcpkg_execute_required_process(
    COMMAND cmake ../src -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}
    WORKING_DIRECTORY ${SOURCE_PATH}/build
)

vcpkg_execute_required_process(
    COMMAND make install -j ${VCPKG_CONCURRENCY}
    WORKING_DIRECTORY ${SOURCE_PATH}/build
)

vcpkg_execute_required_process(
    COMMAND make -j ${VCPKG_CONCURRENCY}
    WORKING_DIRECTORY ${SOURCE_PATH}/build
)

file(INSTALL
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    TYPE FILE
    FILES ${SOURCE_PATH}/build/output/libswift_net.a
)

file(INSTALL
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
    TYPE DIRECTORY
    FILES ${SOURCE_PATH}/src/swift_net.h
)

vcpkg_copy_pdbs()
