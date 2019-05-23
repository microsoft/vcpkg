#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/RxCpp-4.0.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Reactive-Extensions/RxCpp
    REF v4.1.0
    SHA512 a92e817ecbdf6f235cae724ada2615af9fa0c243249625d0f2c2f09ff5dd7f53fdabd03a0278fe2995fe27528c5511d71f87b7a6b3d54f73b49b65aef56e32fd
    HEAD_REF master
)

file(INSTALL
	${SOURCE_PATH}/Rx/v2/src/rxcpp
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL
	${SOURCE_PATH}/Ix/CPP/src/cpplinq
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL
	${SOURCE_PATH}/license.md
	DESTINATION ${CURRENT_PACKAGES_DIR}/share/rxcpp RENAME copyright)