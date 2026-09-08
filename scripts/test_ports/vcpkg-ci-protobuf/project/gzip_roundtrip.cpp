#include <google/protobuf/io/gzip_stream.h>
#include <google/protobuf/io/zero_copy_stream_impl_lite.h>

#include <algorithm>
#include <cstring>
#include <iostream>
#include <string>

int main() {
    const std::string original(4096, 'p');
    std::string compressed;
    {
        google::protobuf::io::StringOutputStream sink(&compressed);
        google::protobuf::io::GzipOutputStream gzip(&sink);
        std::size_t offset = 0;
        while (offset < original.size()) {
            void* buffer = nullptr;
            int capacity = 0;
            if (!gzip.Next(&buffer, &capacity)) {
                return 1;
            }
            const auto copied = std::min(original.size() - offset, static_cast<std::size_t>(capacity));
            std::memcpy(buffer, original.data() + offset, copied);
            gzip.BackUp(capacity - static_cast<int>(copied));
            offset += copied;
        }
        if (!gzip.Close()) {
            return 2;
        }
    }
    google::protobuf::io::ArrayInputStream source(compressed.data(), static_cast<int>(compressed.size()));
    google::protobuf::io::GzipInputStream gzip(&source);
    std::string restored;
    const void* buffer = nullptr;
    int count = 0;
    while (gzip.Next(&buffer, &count)) {
        restored.append(static_cast<const char*>(buffer), count);
    }
    if (restored != original || compressed.size() >= original.size()) {
        return 3;
    }
    std::cout << "gzip round-trip passed; compressed_bytes=" << compressed.size() << '\n';
}
