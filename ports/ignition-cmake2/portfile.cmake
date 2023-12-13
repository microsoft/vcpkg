set(PACKAGE_VERSION "2.16.0")

ignition_modular_library(NAME cmake
                         VERSION ${PACKAGE_VERSION}
                         SHA512 6ee64ff6c82c657678188be459c50a4255fd3881d758906d93361425702d04854a13a46124b20e058069f314077ba7e6c15a058153b615b3245084f066d1cbae
                         PATCHES
                            add-pkgconfig-and-remove-privatefor-limit.patch
                            fix-findogre-pkgconfig.patch)

# Install custom usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
