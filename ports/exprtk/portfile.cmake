vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArashPartow/exprtk
    REF A4B17D543F072D2E3BA564E4BC5C3A0D2B05C338
    SHA512 17CFD8521BF7E9213131351F697983F8E33E00CEC4EEE43FAF2FEE4C3FB6A9BEDAE54C84BD69CF64E8CCBCA353C2AED7048DCF6FC20F631CF23C8219C02A68F2
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/exprtk.hpp DESTINATION "${CURRENT_PACKAGES_DIR}/include")
vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/copyright")
