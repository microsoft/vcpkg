#include "lite.pb.h"

#include <cstdint>
#include <iostream>
#include <string>
#include <type_traits>

static_assert(std::is_base_of_v<google::protobuf::MessageLite, vcpkg_test::LiteMessage>);

int main() {
    vcpkg_test::LiteMessage original;
    original.set_id(UINT64_C(9007199254740993));
    original.set_name("protobuf-lite");
    original.set_payload(std::string("a\0b\xff", 4));
    original.add_values(-12345);
    original.add_values(67890);
    (*original.mutable_counts())["messages"] = 2;

    std::string wire;
    if (!original.SerializeToString(&wire)) {
        return 1;
    }
    vcpkg_test::LiteMessage restored;
    if (!restored.ParseFromString(wire)) {
        return 2;
    }
    const auto count = restored.counts().find("messages");
    if (restored.id() != original.id() ||
        restored.name() != original.name() || restored.payload() != original.payload() ||
        restored.values_size() != 2 || restored.values(0) != -12345 ||
        restored.values(1) != 67890 || count == restored.counts().end() || count->second != 2) {
        return 3;
    }
    std::cout << "lite round-trip passed; wire_bytes=" << wire.size() << '\n';
}
