#include <hello_imgui/hello_imgui.h>

int main()
{
    HelloImGui::Run([]() {
        ImGui::Text("Hello vcpkg");
        ImGui::ShowDemoWindow();
    });
    return 0;
}
