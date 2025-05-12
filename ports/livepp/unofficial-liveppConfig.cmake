add_library(unofficial::livepp::livepp INTERFACE IMPORTED)
set_target_properties(unofficial::livepp::livepp PROPERTIES
     INTERFACE_COMPILE_DEFINITIONS LIVEPP_PATH="${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/tools/livepp")