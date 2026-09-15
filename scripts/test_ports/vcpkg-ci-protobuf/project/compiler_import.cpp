#include <google/protobuf/compiler/code_generator.h>
#include <google/protobuf/compiler/command_line_interface.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/io/printer.h>
#include <google/protobuf/io/zero_copy_stream.h>

#include <fstream>
#include <iostream>
#include <iterator>
#include <memory>
#include <string>

class SchemaGenerator final : public google::protobuf::compiler::CodeGenerator {
public:
    bool Generate(const google::protobuf::FileDescriptor* file, const std::string&,
                  google::protobuf::compiler::GeneratorContext* context,
                  std::string* error) const override {
        if (file->message_type_count() != 1 || file->message_type(0)->field_count() != 5) {
            *error = "Unexpected imported schema";
            return false;
        }
        std::unique_ptr<google::protobuf::io::ZeroCopyOutputStream> output(context->Open("schema.txt"));
        google::protobuf::io::Printer printer(output.get(), '$');
        printer.PrintRaw(file->message_type(0)->full_name());
        return !printer.failed();
    }
};

int main(int argc, char** argv) {
    if (argc != 3) {
        return 1;
    }
    SchemaGenerator generator;
    google::protobuf::compiler::CommandLineInterface compiler;
    compiler.RegisterGenerator("--schema_out", &generator, "Generate a schema summary");
    const std::string include = std::string("--proto_path=") + argv[1];
    const std::string output = std::string("--schema_out=") + argv[2];
    const char* arguments[] = {"vcpkg-libprotoc-test", include.c_str(), output.c_str(), "lite.proto"};
    if (compiler.Run(4, arguments) != 0) {
        return 2;
    }
    std::ifstream summary(std::string(argv[2]) + "/schema.txt");
    const std::string contents((std::istreambuf_iterator<char>(summary)), std::istreambuf_iterator<char>());
    if (contents != "vcpkg_test.LiteMessage") {
        return 3;
    }
    std::cout << "libprotoc schema import and public generator API passed\n";
}
