# Download the docking branch source from GitHub at a fixed commit
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ocornut/imgui
    REF 8ccff821533bed25fb6e8b4bbc44445fdd3609a4
    SHA512 5bb29c5b0102c01d3408e0f1bf171049274faa6ab8e9e1413788abf306f7014e57ab6cd5644bfa7c8d028ba174b8e82662e26f9db7854a1c01c22ff95216c968
)

# Install core ImGui header and source files
file(INSTALL
    ${SOURCE_PATH}/imgui.h
    ${SOURCE_PATH}/imconfig.h
    ${SOURCE_PATH}/imgui.cpp
    ${SOURCE_PATH}/imgui_draw.cpp
    ${SOURCE_PATH}/imgui_widgets.cpp
    ${SOURCE_PATH}/imgui_tables.cpp
    ${SOURCE_PATH}/imgui_demo.cpp
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Install docking backends
file(GLOB BACKENDS
    "${SOURCE_PATH}/backends/*.h"
    "${SOURCE_PATH}/backends/*.cpp"
)
file(INSTALL
    ${BACKENDS}
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/backends
)

# Install LICENSE file to satisfy vcpkg audit
file(INSTALL
    ${SOURCE_PATH}/LICENSE.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/imgui-docking
    RENAME copyright
)