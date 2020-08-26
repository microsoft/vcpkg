/*
 *Copyright (c) 2013-2014, yinqiwen <yinqiwen@gmail.com>
 *All rights reserved.
 *
 *Redistribution and use in source and binary forms, with or without
 *modification, are permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of Redis nor the names of its contributors may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 *THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 *BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "pbjson.hpp"
#include "bin2ascii.h"
#include "rapidjson/rapidjson.h"
#include "rapidjson/writer.h"
#include "rapidjson/stringbuffer.h"

#define RETURN_ERR(id, cause)  do{\
                                  err = cause; \
                                  return id;   \
                              }while(0)
using namespace google::protobuf;
namespace pbjson
{
    static rapidjson::Value *parse_msg(const Message *msg, rapidjson::Value::AllocatorType& allocator);
    static rapidjson::Value* field2json(const Message *msg, const FieldDescriptor *field,
            rapidjson::Value::AllocatorType& allocator)
    {
        const Reflection *ref = msg->GetReflection();
        const bool repeated = field->is_repeated();

        size_t array_size = 0;
        if (repeated)
        {
            array_size = ref->FieldSize(*msg, field);
        }
        rapidjson::Value* json = NULL;
        if (repeated)
        {
            json = new rapidjson::Value(rapidjson::kArrayType);
        }
        switch (field->cpp_type())
        {
            case FieldDescriptor::CPPTYPE_DOUBLE:
                if (repeated)
                {
                    for (size_t i = 0; i != array_size; ++i)
                    {
                        double value = ref->GetRepeatedDouble(*msg, field, i);
                        rapidjson::Value v(value);
                        json->PushBack(v, allocator);
                    }
                }
                else
                {
                    json = new rapidjson::Value(ref->GetDouble(*msg, field));
                }
                break;
            case FieldDescriptor::CPPTYPE_FLOAT:
                if (repeated)
                {
                    for (size_t i = 0; i != array_size; ++i)
                    {
                        float value = ref->GetRepeatedFloat(*msg, field, i);
                        rapidjson::Value v(value);
                        json->PushBack(v, allocator);
                    }
                }
                else
                {
                    json = new rapidjson::Value(ref->GetFloat(*msg, field));
                }
                break;
            case FieldDescriptor::CPPTYPE_INT64:
                if (repeated)
                {
                    for (size_t i = 0; i != array_size; ++i)
                    {
                        int64_t value = ref->GetRepeatedInt64(*msg, field, i);
                        rapidjson::Value v(value);
                        json->PushBack(v, allocator);
                    }
                }
                else
                {
                    json = new rapidjson::Value(static_cast<int64_t>(ref->GetInt64(*msg, field)));
                }
                break;
            case FieldDescriptor::CPPTYPE_UINT64:
                if (repeated)
                {
                    for (size_t i = 0; i != array_size; ++i)
                    {
                        uint64_t value = ref->GetRepeatedUInt64(*msg, field, i);
                        rapidjson::Value v(value);
                        json->PushBack(v, allocator);
                    }
                }
                else
                {
                    json = new rapidjson::Value(static_cast<uint64_t>(ref->GetUInt64(*msg, field)));
                }
                break;
            case FieldDescriptor::CPPTYPE_INT32:
                if (repeated)
                {
                    for (size_t i = 0; i != array_size; ++i)
                    {
                        int32_t value = ref->GetRepeatedInt32(*msg, field, i);
                        rapidjson::Value v(value);
                        json->PushBack(v, allocator);
                    }
                }
                else
                {
                    json = new rapidjson::Value(ref->GetInt32(*msg, field));
                }
                break;
            case FieldDescriptor::CPPTYPE_UINT32:
                if (repeated)
                {
                    for (size_t i = 0; i != array_size; ++i)
                    {
                        uint32_t value = ref->GetRepeatedUInt32(*msg, field, i);
                        rapidjson::Value v(value);
                        json->PushBack(v, allocator);
                    }
                }
                else
                {
                    json = new rapidjson::Value(ref->GetUInt32(*msg, field));
                }
                break;
            case FieldDescriptor::CPPTYPE_BOOL:
                if (repeated)
                {
                    for (size_t i = 0; i != array_size; ++i)
                    {
                        bool value = ref->GetRepeatedBool(*msg, field, i);
                        rapidjson::Value v(value);
                        json->PushBack(v, allocator);
                    }
                }
                else
                {
                    json = new rapidjson::Value(ref->GetBool(*msg, field));
                }
                break;
            case FieldDescriptor::CPPTYPE_STRING:
            {
                bool is_binary = field->type() == FieldDescriptor::TYPE_BYTES;
                if (repeated)
                {
                    for (size_t i = 0; i != array_size; ++i)
                    {
                        std::string value = ref->GetRepeatedString(*msg, field, i);
                        if (is_binary)
                        {
                            value = b64_encode(value);
                        }
                        rapidjson::Value v(value.c_str(), static_cast<rapidjson::SizeType>(value.size()), allocator);
                        json->PushBack(v, allocator);
                    }
                }
                else
                {
                    std::string value = ref->GetString(*msg, field);
                    if (is_binary)
                    {
                        value = b64_encode(value);
                    }
                    json = new rapidjson::Value(value.c_str(), value.size(), allocator);
                }
                break;
            }
            case FieldDescriptor::CPPTYPE_MESSAGE:
                if (repeated)
                {
                    for (size_t i = 0; i != array_size; ++i)
                    {
                        const Message *value = &(ref->GetRepeatedMessage(*msg, field, i));
                        rapidjson::Value* v = parse_msg(value, allocator);
                        json->PushBack(*v, allocator);
                        delete v;
                    }
                }
                else
                {
                    const Message *value = &(ref->GetMessage(*msg, field));
                    json = parse_msg(value, allocator);
                }
                break;
            case FieldDescriptor::CPPTYPE_ENUM:
                if (repeated)
                {
                    for (size_t i = 0; i != array_size; ++i)
                    {
                        const EnumValueDescriptor* value = ref->GetRepeatedEnum(*msg, field, i);
                        rapidjson::Value v(value->number());
                        json->PushBack(v, allocator);
                    }
                }
                else
                {
                    json = new rapidjson::Value(ref->GetEnum(*msg, field)->number());
                }
                break;
            default:
                break;
        }
        return json;
    }

    static rapidjson::Value* parse_msg(const Message *msg, rapidjson::Value::AllocatorType& allocator)
    {
        const Descriptor *d = msg->GetDescriptor();
        if (!d)
            return NULL;
        size_t count = d->field_count();
        rapidjson::Value* root = new rapidjson::Value(rapidjson::kObjectType);
        if (!root)
            return NULL;
        for (size_t i = 0; i != count; ++i)
        {
            const FieldDescriptor *field = d->field(i);
            if (!field){
                delete root;
                return NULL;
            }

            const Reflection *ref = msg->GetReflection();
            if (!ref)
            {
                delete root;
                return NULL;
            }
            if (field->is_optional() && !ref->HasField(*msg, field))
            {
                //do nothing
            }
            else
            {
                rapidjson::Value* field_json = field2json(msg, field, allocator);
                rapidjson::Value field_name(field->name().c_str(), field->name().size());
                root->AddMember(field_name, *field_json, allocator);
                delete field_json;
            }
        }
        return root;
    }
    static int parse_json(const rapidjson::Value* json, Message* msg, std::string& err);
    static int json2field(const rapidjson::Value* json, Message* msg, const FieldDescriptor *field, std::string& err)
    {
        const Reflection *ref = msg->GetReflection();
        const bool repeated = field->is_repeated();
        switch (field->cpp_type())
        {
            case FieldDescriptor::CPPTYPE_INT32:
            {
                if (json->GetType() != rapidjson::kNumberType)
                {
                    RETURN_ERR(ERR_INVALID_JSON, "Not a number");
                }
                if (repeated)
                {
                    ref->AddInt32(msg, field, (int32_t) json->GetInt());
                }
                else
                {
                    ref->SetInt32(msg, field, (int32_t) json->GetInt());
                }
                break;
            }
            case FieldDescriptor::CPPTYPE_UINT32:
            {
                if (json->GetType() != rapidjson::kNumberType)
                {
                    RETURN_ERR(ERR_INVALID_JSON, "Not a number");
                }
                if (repeated)
                {
                    ref->AddUInt32(msg, field, json->GetUint());
                }
                else
                {
                    ref->SetUInt32(msg, field, json->GetUint());
                }
                break;
            }
            case FieldDescriptor::CPPTYPE_INT64:
            {
                if (json->GetType() != rapidjson::kNumberType)
                {
                    RETURN_ERR(ERR_INVALID_JSON, "Not a number");
                }
                if (repeated)
                {
                    ref->AddInt64(msg, field, json->GetInt64());
                }
                else
                {
                    ref->SetInt64(msg, field, json->GetInt64());
                }
                break;
            }
            case FieldDescriptor::CPPTYPE_UINT64:
            {
                if (json->GetType() != rapidjson::kNumberType)
                {
                    RETURN_ERR(ERR_INVALID_JSON, "Not a number");
                }
                if (repeated)
                {
                    ref->AddUInt64(msg, field, json->GetUint64());
                }
                else
                {
                    ref->SetUInt64(msg, field, json->GetUint64());
                }
                break;
            }
            case FieldDescriptor::CPPTYPE_DOUBLE:
            {
                if (json->GetType() != rapidjson::kNumberType)
                {
                    RETURN_ERR(ERR_INVALID_JSON, "Not a number");
                }
                if (repeated)
                {
                    ref->AddDouble(msg, field, json->GetDouble());
                }
                else
                {
                    ref->SetDouble(msg, field, json->GetDouble());
                }
                break;
            }
            case FieldDescriptor::CPPTYPE_FLOAT:
            {
                if (json->GetType() != rapidjson::kNumberType)
                {
                    RETURN_ERR(ERR_INVALID_JSON, "Not a number");
                }
                if (repeated)
                {
                    ref->AddFloat(msg, field, json->GetDouble());
                }
                else
                {
                    ref->SetFloat(msg, field, json->GetDouble());
                }
                break;
            }
            case FieldDescriptor::CPPTYPE_BOOL:
            {
                if (json->GetType() != rapidjson::kTrueType && json->GetType() != rapidjson::kFalseType)
                {
                    RETURN_ERR(ERR_INVALID_JSON, "Not a bool");
                }
                bool v = json->GetBool();
                if (repeated)
                {
                    ref->AddBool(msg, field, v);
                }
                else
                {
                    ref->SetBool(msg, field, v);
                }
                break;
            }
            case FieldDescriptor::CPPTYPE_STRING:
            {
                if (json->GetType() != rapidjson::kStringType)
                {
                    RETURN_ERR(ERR_INVALID_JSON, "Not a string");
                }
                const char* value = json->GetString();
                uint32_t str_size = json->GetStringLength();
                std::string str_value(value, str_size);
                if (field->type() == FieldDescriptor::TYPE_BYTES)
                {
                    if (repeated)
                    {
                        ref->AddString(msg, field, b64_decode(str_value));
                    }
                    else
                    {
                        ref->SetString(msg, field, b64_decode(str_value));
                    }
                }
                else
                {
                    if (repeated)
                    {
                        ref->AddString(msg, field, str_value);
                    }
                    else
                    {
                        ref->SetString(msg, field, str_value);
                    }
                }
                break;
            }
            case FieldDescriptor::CPPTYPE_MESSAGE:
            {
                Message *mf = (repeated) ? ref->AddMessage(msg, field) : ref->MutableMessage(msg, field);
                return parse_json(json, mf, err);
            }
            case FieldDescriptor::CPPTYPE_ENUM:
            {
                const EnumDescriptor *ed = field->enum_type();
                const EnumValueDescriptor *ev = 0;
                if (json->GetType() == rapidjson::kNumberType)
                {
                    ev = ed->FindValueByNumber(json->GetInt());
                }
                else if (json->GetType() == rapidjson::kStringType)
                {
                    ev = ed->FindValueByName(json->GetString());
                }
                else
                    RETURN_ERR(ERR_INVALID_JSON, "Not an integer or string");
                if (!ev)
                    RETURN_ERR(ERR_INVALID_JSON, "Enum value not found");
                if (repeated)
                {
                    ref->AddEnum(msg, field, ev);
                }
                else
                {
                    ref->SetEnum(msg, field, ev);
                }
                break;
            }
            default:
                break;
        }
        return 0;
    }

    static int parse_json(const rapidjson::Value* json, Message* msg, std::string& err)
    {
        if (NULL == json || json->GetType() != rapidjson::kObjectType)
        {
            return ERR_INVALID_ARG;
        }
        const Descriptor *d = msg->GetDescriptor();
        const Reflection *ref = msg->GetReflection();
        if (!d || !ref)
        {
            RETURN_ERR(ERR_INVALID_PB, "invalid pb object");
        }
        for (rapidjson::Value::ConstMemberIterator itr = json->MemberBegin(); itr != json->MemberEnd(); ++itr)
        {
            const char* name = itr->name.GetString();
            const FieldDescriptor *field = d->FindFieldByName(name);
            if (!field)
                field = ref->FindKnownExtensionByName(name);
            if (!field)
                continue; // TODO: we should not fail here, instead write this value into an unknown field
            if (itr->value.GetType() == rapidjson::kNullType) {
                ref->ClearField(msg, field);
                continue;
            }
            if (field->is_repeated())
            {
                if (itr->value.GetType() != rapidjson::kArrayType)
                    RETURN_ERR(ERR_INVALID_JSON, "Not array");
                for (rapidjson::Value::ConstValueIterator ait = itr->value.Begin(); ait != itr->value.End(); ++ait)
                {
                    int ret = json2field(ait, msg, field, err);
                    if (ret != 0)
                    {
                        return ret;
                    }
                }
            }
            else
            {
                int ret = json2field(&(itr->value), msg, field, err);
                if (ret != 0)
                {
                    return ret;
                }
            }
        }
        return 0;
    }

    void json2string(const rapidjson::Value* json, std::string& str)
    {
        rapidjson::StringBuffer buffer;
        rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
        json->Accept(writer);
        str.append(buffer.GetString(), buffer.GetSize());
    }

    void pb2json(const Message* msg, std::string& str)
    {
        rapidjson::Value::AllocatorType allocator;
        rapidjson::Value* json = parse_msg(msg, allocator);
        json2string(json, str);
        delete json;
    }

    rapidjson::Value* pb2jsonobject(const google::protobuf::Message* msg)
    {
        rapidjson::Value::AllocatorType allocator;
        return parse_msg(msg, allocator);
    }

    rapidjson::Value* pb2jsonobject(const google::protobuf::Message* msg, rapidjson::Value::AllocatorType& allocator)
    {
        return parse_msg(msg, allocator);
    }

    int json2pb(const std::string& json, google::protobuf::Message* msg, std::string& err)
    {
        rapidjson::Document d;
        d.Parse<0>(json.c_str());
        if (d.HasParseError())
        {
            err += d.GetParseError();
            return ERR_INVALID_ARG;
        }
        int ret = jsonobject2pb(&d, msg, err);
        return ret;
    }
    int jsonobject2pb(const rapidjson::Value* json, google::protobuf::Message* msg, std::string& err)
    {
        return parse_json(json, msg, err);
    }

}
