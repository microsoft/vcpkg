# Ports Options

**Note: this is a RFC and currently not implemented**

## Motivation

There are a number of ports that require fine-grained configuration or exclusive options, and for which the only current options are abusing features, or requiring most users to make an overlay port only to change a few variables. Both those options are suboptimal, which is what this RFC aims to fix.

## Limitations of features

Conceptually, features are sets of named boolean flags. It has some consequences making them unsuited to some use-cases when it comes to fine-grained configuration:

* Features are boolean options: either a feature is enabled or it isn't. It makes it hard to represent options which can have more than two values.
* Features are additive. But for example changing the the ssl implementation from openssl to boringssl is not a additive feature but a exclusive decision between two values. 

## The options object 

The options objects should have the same structure as the feature object. In the following an example for a choices and string option is shown:
**`vcpkg.json`**
```json5
{
  "name": "foobar",
  "description": "super duper",
  "dependencies": [...],
  "features": {}, 
  "options": {
    "foo": { // an example `choices`/enum option field
      "description": "Name", // Not required
      "choices": [ // required
        "bar",
        "dor",
        {
          "name": "test",
          "description": "42", // Is this needed? 
          "dependencies": [] // dependencies when this option is selected
        }
      ],
      "default": "bar", // required
    },
    "assert-action": { // an string option field, for example needed for https://github.com/microsoft/vcpkg/discussions/19632
      // use https://github.com/ocornut/imgui/blob/master/imconfig.h#L17 as an example
      "description": "Define assertion handler. Defaults to calling assert(). Use _EXPR to access the parameter.", // required
      "type": "string", // required
      "examples": ["MyAssert(_EXPR)", "((void)(_EXPR))"],  // not required
      "default": null  // required, allow null to use the default value of the lib
    }
  }
}
```

### Other types as option values
Other possible types are:
- booleans: Booleans can theoretically be emulated by a choices field with the choices `enabled` and `disabled` (or `yes`/`no`). But it can be less verbose to use boolean fields for that. Example:
  ```json5
  "options": {
      "some_option": {
        "description": "Switch between ...", // required
        "type": "boolean", // required
        "default": false // required
      }
    }
  ```  
  But since boolean fields are often covered by features (like enable dependency *xy*) and no use case is currently known, they will be not implemented.

- numbers: We can also add a numbers field, but no use case is currently known.

### Textual representation
When a port must be represented textually the form `name[features...]:triplet` is used, with options this should be extended to `name[features...,options...]:triplet` where options are key-value pairs of the form `key=value` separated by commas.  
If a value of an option is selected because it is the default, the corresponding `key=value` entry can be omitted.  

## Selecting options in manifest files
A dependency entry:
```json5
{
  "name": "foobar", // from the manifest file above
  "features": [...],
  "options": { // A key-value mapping
    "foo": "dor",
    "bar": "MyString"
  }
}
```

## Resolution of option selections
If for an option no value is specified, the default value is used. If a dependency entry don't specify a value for an option, it does not care about the final value of the option. If a dependency entry specifies a value for an option, it is guaranteed that the option will have this value. If there are two dependency entries in the dependency tree that require a different value for an option of some port vcpkg should exit with an error.  
For this reason, ports should only require a value for an option of one of their dependencies if it is really necessary. One use case can be that a port can have an Qt5 or Qt6 compatible API interface, so it can depend on Qt5 or Qt6. The end user can then select between the used Qt version. But if we now have a Qt5 or Qt6 only port, this port can require the value Qt5 or Qt6 from the dependency. 

## Possible extension: Options in features
**Disclaimer**: Since no use case is currently known, it will not be implemented for the time being.  
The options object is allowed at the root of a manifest file. Additionally it is available at each feature object. Reason: Imagine we have a library `Foo` that has a feature `bar` that then depends on some lib `A`, but this feature could also be implemented with library `B`. We now could make it an option with the values `None`, `libA`, `libB`, but then other ports that depends on `Foo` and need the `bar` feature have to decide between `A` and `B` or have to make it an option themselves, but in reality they don't care.  If we now allow options at a feature level, we can have a feature `bar` that then has two options `libA` and `libB`. Then other ports can simply depend on `Foo` with the `bar` feature.  

### Selection of options in features
Imagine we have the following port:
```json5
{
  "name": "feature-options",
  "description": "super nice",  
  "features": {
    "Foo": {
      "description": "Super feature",
      "options": {
        "lib": { 
          "choices": [
            {
              "name": "libA",
              "dependencies": ["A"]
            },
            {
              "name": "libB",
              "dependencies": ["B"]
            }
          ],
          "default": "libA",
        },
      }      
    }
  }
}
```
If a end user want to select `B` the following can be used:
```json5
{
  "name": "feature-options",
  "features": [
    {
      "name": "bar",
      "options": {
        "lib": "libB"
      }
    }
  ]
}
```

#### Textual representation
The general representation should be `name[features[options...]...,options...]:triplet`. For the example above that would be `feature-options[Foo[lib=libB]]`

## Option selection in classic mode
I am now sure how this should work, feel free to comment.  
Problems: Imagine the `foobar` port from above. What should happen in the following case:
1. `vcpkg install foobar[foo=dor]`
2. `vcpkg install foobar[foo=bar]`
3. `vcpkg install foobar[bar=QString]`
4. Install some dependency that needs `foobar[foo=dor]`

I currently see three possible options:
1. Only the default optional values are allowed
2. You must remove the package if options were selected
3. Options are overwritten by the newest install command, but existing selection must proceed if not explicitly overwritten. For example the command *3* changes the `bar` option from `std::string` to `QString`, but the `foo` value should stay at the value `bar`. 
4. Like option 3, but print an error when a selection is changed from an explicit selected one to a new one by an dependency. So command 2 would be successfully, but command 4 would fail. But it should be possible to pass a flag to overwrite the existing feature selection. 

I probably would vote for option 4.
