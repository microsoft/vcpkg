#include "full.pb.h"

#include <google/protobuf/text_format.h>

#include <iostream>
#include <string>

int main() {
    vcpkg_test::FullMessage original;
    const auto* descriptor = original.GetDescriptor();
    const auto* reflection = original.GetReflection();
    const auto* id = descriptor->FindFieldByName("id");
    const auto* name = descriptor->FindFieldByName("name");
    if (!id || !name) {
        return 1;
    }
    reflection->SetInt32(&original, id, 42);
    reflection->SetString(&original, name, "full-runtime");

    std::string text;
    vcpkg_test::FullMessage restored;
    if (!google::protobuf::TextFormat::PrintToString(original, &text) ||
        !google::protobuf::TextFormat::ParseFromString(text, &restored) ||
        restored.id() != 42 || restored.name() != "full-runtime") {
        return 2;
    }
    std::cout << "reflection and text round-trip passed\n";
}
