include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArashPartow/exprtk
    REF d89d2f5f46fbd33372c81e8ad4b997fa84569fae
    SHA512 bad42b83a0f1d8142ceafac862ec62dafc040fa8293bfbca29e49afdc8dca1000fc43537a5cf28d1dae00f5e86516899bd37f996975fbbccdd6a8298d1adb359
)

file(COPY ${SOURCE_PATH}/exprtk.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/exprtk)
