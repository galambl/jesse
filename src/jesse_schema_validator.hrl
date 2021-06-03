%%%=============================================================================
%% Copyright 2012- Klarna AB
%% Copyright 2015- AUTHORS
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% @doc Json schema validation module.
%%
%% This module is the core of jesse, it implements the validation functionality
%% according to the standard.
%% @end
%%%=============================================================================

%% Maps conditional compilation
-ifdef(erlang_deprecated_types).
-define(IF_MAPS(Exp), ).
-else.
-define(IF_MAPS(Exp), Exp).
-endif.

%% Constant definitions for Json schema keywords
-define(SCHEMA,               '$schema').
-define(TYPE,                 'type').
-define(PROPERTIES,           'properties').
-define(PATTERNPROPERTIES,    'patternProperties').
-define(ADDITIONALPROPERTIES, 'additionalProperties').
-define(ITEMS,                'items').
-define(ADDITIONALITEMS,      'additionalItems').
-define(REQUIRED,             'required').
-define(DEPENDENCIES,         'dependencies').
-define(MINIMUM,              'minimum').
-define(MAXIMUM,              'maximum').
-define(EXCLUSIVEMINIMUM,     'exclusiveMinimum').
-define(EXCLUSIVEMAXIMUM,     'exclusiveMaximum').
-define(MINITEMS,             'minItems').
-define(MAXITEMS,             'maxItems').
-define(UNIQUEITEMS,          'uniqueItems').
-define(PATTERN,              'pattern').
-define(MINLENGTH,            'minLength').
-define(MAXLENGTH,            'maxLength').
-define(ENUM,                 'enum').
-define(FORMAT,               'format').               % NOT IMPLEMENTED YET
-define(DIVISIBLEBY,          'divisibleBy').
-define(DISALLOW,             'disallow').
-define(EXTENDS,              'extends').
-define(ID,                   'id').
-define(REF,                  '$ref').
-define(ALLOF,                'allOf').
-define(ANYOF,                'anyOf').
-define(ONEOF,                'oneOf').
-define(NOT,                  'not').
-define(MULTIPLEOF,           'multipleOf').
-define(MAXPROPERTIES,        'maxProperties').
-define(MINPROPERTIES,        'minProperties').

%% Constant definitions for Json types
-define(ANY,                  'any').
-define(ARRAY,                'array').
-define(BOOLEAN,              'boolean').
-define(INTEGER,              'integer').
-define(NULL,                 'null').
-define(NUMBER,               'number').
-define(OBJECT,               'object').
-define(STRING,               'string').

%% Constant definitions for Json schema keywords in binary
-define(SCHEMA_B,               <<"$schema">>).
-define(TYPE_B,                 <<"type">>).
-define(PROPERTIES_B,           <<"properties">>).
-define(PATTERNPROPERTIES_B,    <<"patternProperties">>).
-define(ADDITIONALPROPERTIES_B, <<"additionalProperties">>).
-define(ITEMS_B,                <<"items">>).
-define(ADDITIONALITEMS_B,      <<"additionalItems">>).
-define(REQUIRED_B,             <<"required">>).
-define(DEPENDENCIES_B,         <<"dependencies">>).
-define(MINIMUM_B,              <<"minimum">>).
-define(MAXIMUM_B,              <<"maximum">>).
-define(EXCLUSIVEMINIMUM_B,     <<"exclusiveMinimum">>).
-define(EXCLUSIVEMAXIMUM_B,     <<"exclusiveMaximum">>).
-define(MINITEMS_B,             <<"minItems">>).
-define(MAXITEMS_B,             <<"maxItems">>).
-define(UNIQUEITEMS_B,          <<"uniqueItems">>).
-define(PATTERN_B,              <<"pattern">>).
-define(MINLENGTH_B,            <<"minLength">>).
-define(MAXLENGTH_B,            <<"maxLength">>).
-define(ENUM_B,                 <<"enum">>).
-define(FORMAT_B,               <<"format">>).               % NOT IMPLEMENTED YET
-define(DIVISIBLEBY_B,          <<"divisibleBy">>).
-define(DISALLOW_B,             <<"disallow">>).
-define(EXTENDS_B,              <<"extends">>).
-define(ID_B,                   <<"id">>).
-define(REF_B,                  <<"$ref">>).
-define(ALLOF_B,                <<"allOf">>).
-define(ANYOF_B,                <<"anyOf">>).
-define(ONEOF_B,                <<"oneOf">>).
-define(NOT_B,                  <<"not">>).
-define(MULTIPLEOF_B,           <<"multipleOf">>).
-define(MAXPROPERTIES_B,        <<"maxProperties">>).
-define(MINPROPERTIES_B,        <<"minProperties">>).

%% Constant definitions for Json types in binary
-define(ANY_B,                  <<"any">>).
-define(ARRAY_B,                <<"array">>).
-define(BOOLEAN_B,              <<"boolean">>).
-define(INTEGER_B,              <<"integer">>).
-define(NULL_B,                 <<"null">>).
-define(NUMBER_B,               <<"number">>).
-define(OBJECT_B,               <<"object">>).
-define(STRING_B,               <<"string">>).


%%----------------------------------------------------
-define(IS_SCHEMA(Data),               Data =:= ?SCHEMA orelse
                                       Data =:= ?SCHEMA_B).
-define(IS_TYPE(Data),                 Data =:= ?TYPE orelse
                                       Data =:= ?TYPE_B).
-define(IS_PROPERTIES(Data),           Data =:= ?PROPERTIES orelse
                                       Data =:= ?PROPERTIES_B).
-define(IS_PATTERNPROPERTIES(Data),    Data =:= ?PATTERNPROPERTIES orelse
                                       Data =:= ?PATTERNPROPERTIES_B).
-define(IS_ADDITIONALPROPERTIES(Data), Data =:= ?ADDITIONALPROPERTIES orelse
                                       Data =:= ?ADDITIONALPROPERTIES_B).
-define(IS_ITEMS(Data),                Data =:= ?ITEMS orelse
                                       Data =:= ?ITEMS_B).
-define(IS_ADDITIONALITEMS(Data),      Data =:= ?ADDITIONALITEMS orelse
                                       Data =:= ?ADDITIONALITEMS_B).
-define(IS_REQUIRED(Data),             Data =:= ?REQUIRED orelse
                                       Data =:= ?REQUIRED_B).
-define(IS_DEPENDENCIES(Data),         Data =:= ?DEPENDENCIES orelse
                                       Data =:= ?DEPENDENCIES_B).
-define(IS_MINIMUM(Data),              Data =:= ?MINIMUM orelse
                                       Data =:= ?MINIMUM_B).
-define(IS_MAXIMUM(Data),              Data =:= ?MAXIMUM orelse
                                       Data =:= ?MAXIMUM_B).
-define(IS_EXCLUSIVEMINIMUM(Data),     Data =:= ?EXCLUSIVEMINIMUM orelse
                                       Data =:= ?EXCLUSIVEMINIMUM_B).
-define(IS_EXCLUSIVEMAXIMUM(Data),     Data =:= ?EXCLUSIVEMAXIMUM orelse
                                       Data =:= ?EXCLUSIVEMAXIMUM_B).
-define(IS_MINITEMS(Data),             Data =:= ?MINITEMS orelse
                                       Data =:= ?MINITEMS_B).
-define(IS_MAXITEMS(Data),             Data =:= ?MAXITEMS orelse
                                       Data =:= ?MAXITEMS_B).
-define(IS_UNIQUEITEMS(Data),          Data =:= ?UNIQUEITEMS orelse
                                       Data =:= ?UNIQUEITEMS_B).
-define(IS_PATTERN(Data),              Data =:= ?PATTERN orelse
                                       Data =:= ?PATTERN_B).
-define(IS_MINLENGTH(Data),            Data =:= ?MINLENGTH orelse
                                       Data =:= ?MINLENGTH_B).
-define(IS_MAXLENGTH(Data),            Data =:= ?MAXLENGTH orelse
                                       Data =:= ?MAXLENGTH_B).
-define(IS_ENUM(Data),                 Data =:= ?ENUM orelse
                                       Data =:= ?ENUM_B).
-define(IS_FORMAT(Data),               Data =:= ?FORMAT orelse
                                       Data =:= ?FORMAT_B).    % NOT IMPLEMENTED YET
-define(IS_DIVISIBLEBY(Data),          Data =:= ?DIVISIBLEBY orelse
                                       Data =:= ?DIVISIBLEBY_B).
-define(IS_DISALLOW(Data),             Data =:= ?DISALLOW orelse
                                       Data =:= ?DISALLOW_B).
-define(IS_EXTENDS(Data),              Data =:= ?EXTENDS orelse
                                       Data =:= ?EXTENDS_B).
-define(IS_ID(Data),                   Data =:= ?ID orelse
                                       Data =:= ?ID_B).
-define(IS_REF(Data),                  Data =:= ?REF orelse
                                       Data =:= ?REF_B).
-define(IS_ALLOF(Data),                Data =:= ?ALLOF orelse
                                       Data =:= ?ALLOF_B).
-define(IS_ANYOF(Data),                Data =:= ?ANYOF orelse
                                       Data =:= ?ANYOF_B).
-define(IS_ONEOF(Data),                Data =:= ?ONEOF orelse
                                       Data =:= ?ONEOF_B).
-define(IS_NOT(Data),                  Data =:= ?NOT orelse
                                       Data =:= ?NOT_B).
-define(IS_MULTIPLEOF(Data),           Data =:= ?MULTIPLEOF orelse
                                       Data =:= ?MULTIPLEOF_B).
-define(IS_MAXPROPERTIES(Data),        Data =:= ?MAXPROPERTIES orelse
                                       Data =:= ?MAXPROPERTIES_B).
-define(IS_MINPROPERTIES(Data),        Data =:= ?MINPROPERTIES orelse
                                       Data =:= ?MINPROPERTIES_B).

-define(IS_ANY(Data),                  Data =:= ?ANY orelse
                                       Data =:= ?ANY_B).
-define(IS_ARRAY(Data),                Data =:= ?ARRAY orelse
                                       Data =:= ?ARRAY_B).
-define(IS_BOOLEAN(Data),              Data =:= ?BOOLEAN orelse
                                       Data =:= ?BOOLEAN_B).
-define(IS_INTEGER(Data),              Data =:= ?INTEGER orelse
                                       Data =:= ?INTEGER_B).
-define(IS_NULL(Data),                 Data =:= ?NULL orelse
                                       Data =:= ?NULL_B).
-define(IS_NUMBER(Data),               Data =:= ?NUMBER orelse
                                       Data =:= ?NUMBER_B).
-define(IS_OBJECT(Data),               Data =:= ?OBJECT orelse
                                       Data =:= ?OBJECT_B).
-define(IS_STRING(Data),               Data =:= ?STRING orelse
                                       Data =:= ?STRING_B).

%% Supported $schema attributes
-define(json_schema_draft3, <<"http://json-schema.org/draft-03/schema#">>).
-define(json_schema_draft4, <<"http://json-schema.org/draft-04/schema#">>).
-define(default_schema_ver, ?json_schema_draft3).
-define(default_schema_loader_fun, fun jesse_database:load_uri/1).
-define(default_error_handler_fun, fun jesse_error:default_error_handler/3).

%% Constant definitions for schema errors
-define(invalid_dependency,          'invalid_dependency').
-define(only_ref_allowed,            'only_ref_allowed').
-define(schema_error,                'schema_error').
-define(schema_invalid,              'schema_invalid').
-define(schema_not_found,            'schema_not_found').
-define(schema_unsupported,          'schema_unsupported').
-define(wrong_all_of_schema_array,   'wrong_all_of_schema_array').
-define(wrong_any_of_schema_array,   'wrong_any_of_schema_array').
-define(wrong_max_properties,        'wrong_max_properties').
-define(wrong_min_properties,        'wrong_min_properties').
-define(wrong_multiple_of,           'wrong_multiple_of').
-define(wrong_one_of_schema_array,   'wrong_one_of_schema_array').
-define(wrong_required_array,        'wrong_required_array').
-define(wrong_type_dependency,       'wrong_type_dependency').
-define(wrong_type_items,            'wrong_type_items').
-define(wrong_type_specification,    'wrong_type_specification').

%% Constant definitions for data errors
-define(data_error,                  'data_error').
-define(data_invalid,                'data_invalid').
-define(missing_id_field,            'missing_id_field').
-define(missing_required_property,   'missing_required_property').
-define(missing_dependency,          'missing_dependency').
-define(no_match,                    'no_match').
-define(no_extra_properties_allowed, 'no_extra_properties_allowed').
-define(no_extra_items_allowed,      'no_extra_items_allowed').
-define(not_allowed,                 'not_allowed').
-define(not_unique,                  'not_unique').
-define(not_in_enum,                 'not_in_enum').
-define(not_in_range,                'not_in_range').
-define(not_divisible,               'not_divisible').
-define(wrong_type,                  'wrong_type').
-define(wrong_size,                  'wrong_size').
-define(wrong_length,                'wrong_length').
-define(wrong_format,                'wrong_format').
-define(too_many_properties,         'too_many_properties').
-define(too_few_properties,          'too_few_properties').
-define(all_schemas_not_valid,       'all_schemas_not_valid').
-define(any_schemas_not_valid,       'any_schemas_not_valid').
-define(not_multiple_of,             'not_multiple_of').
-define(not_one_schema_valid,        'not_one_schema_valid').
-define(more_than_one_schema_valid,  'more_than_one_schema_valid').
-define(not_schema_valid,            'not_schema_valid').
-define(wrong_not_schema,            'wrong_not_schema').
-define(external,                    'external').

%%
-define(not_found,                   'not_found').
-define(infinity,                    'infinity').
