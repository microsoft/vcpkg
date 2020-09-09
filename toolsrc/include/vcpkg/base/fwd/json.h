#pragma once

#include <vcpkg/base/fwd/optional.h>
#include <vcpkg/base/fwd/span.h>
#include <vcpkg/base/fwd/stringview.h>

namespace vcpkg::Json
{
    struct JsonStyle;
    enum class ValueKind : int;
    struct Value;
    struct Object;
    struct Array;

    struct ReaderError;
    struct BasicReaderError;
    struct Reader;

    // This is written all the way out so that one can include a subclass in a header
    template<class Type>
    struct IDeserializer
    {
        using type = Type;
        virtual StringView type_name() const = 0;

        virtual Span<const StringView> valid_fields() const;

        virtual Optional<Type> visit_null(Reader&);
        virtual Optional<Type> visit_boolean(Reader&, bool);
        virtual Optional<Type> visit_integer(Reader& r, int64_t i);
        virtual Optional<Type> visit_number(Reader&, double);
        virtual Optional<Type> visit_string(Reader&, StringView);
        virtual Optional<Type> visit_array(Reader&, const Array&);
        virtual Optional<Type> visit_object(Reader&, const Object&);

    protected:
        IDeserializer() = default;
        IDeserializer(const IDeserializer&) = default;
        IDeserializer& operator=(const IDeserializer&) = default;
        IDeserializer(IDeserializer&&) = default;
        IDeserializer& operator=(IDeserializer&&) = default;
        virtual ~IDeserializer() = default;
    };
}
