#pragma once

#include <vcpkg/base/files.h>

#include <string>

namespace vcpkg::Hash
{
    enum class Algorithm
    {
        Sha1,
        Sha256,
        Sha512,
    };

    const char* to_string(Algorithm algo) noexcept;
    Optional<Algorithm> algorithm_from_string(StringView sv) noexcept;

    struct Hasher
    {
        virtual void add_bytes(const void* start, const void* end) noexcept = 0;

        // one may only call this once before calling `clear()` or the dtor
        virtual std::string get_hash() noexcept = 0;
        virtual void clear() noexcept = 0;
        virtual ~Hasher() = default;
    };

    std::unique_ptr<Hasher> get_hasher_for(Algorithm algo) noexcept;

    std::string get_bytes_hash(const void* first, const void* last, Algorithm algo) noexcept;
    std::string get_string_hash(StringView s, Algorithm algo) noexcept;
    std::string get_file_hash(const Files::Filesystem& fs,
                              const fs::path& path,
                              Algorithm algo,
                              std::error_code& ec) noexcept;
    inline std::string get_file_hash(LineInfo li,
                                     const Files::Filesystem& fs,
                                     const fs::path& path,
                                     Algorithm algo) noexcept
    {
        std::error_code ec;
        const auto result = get_file_hash(fs, path, algo, ec);
        if (ec)
        {
            Checks::exit_with_message(
                li, "Failure to read file '%s' for hashing: %s", fs::u8string(path), ec.message());
        }

        return result;
    }
}
