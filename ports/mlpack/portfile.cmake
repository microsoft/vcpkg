# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/mlpack
    REF 28eb1858c59e4469da0e9689663a45fc140af9c4 # 4.0.0
    SHA512 b33aa5df48c9f0e5a5fac7bfb69fd2c64bc01f1ba0ae22990774e1805881c60e4652d2f23b6c95627da1a20e39ee6a90e327fdaa6d1e00bac8986dcecc15a89a
    HEAD_REF master
	PATCHES
		0001-Add-a-patch-that-will-hopefully-help-MSVC-debugging.patch
)

# Copy the header files
file(COPY "${SOURCE_PATH}/src/mlpack.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack")
file(COPY "${SOURCE_PATH}/src/mlpack/base.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack")
file(COPY "${SOURCE_PATH}/src/mlpack/prereqs.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack")
file(COPY "${SOURCE_PATH}/src/mlpack/core.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack")
file(COPY "${SOURCE_PATH}/src/mlpack/namespace_compat.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack")
file(COPY "${SOURCE_PATH}/src/mlpack/methods/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack/methods")
file(COPY "${SOURCE_PATH}/src/mlpack/core/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mlpack/core")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT.txt")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
