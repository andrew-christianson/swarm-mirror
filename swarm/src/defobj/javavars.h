#import <defobj/directory.h> // for safe access to jni things

extern jclass c_boolean,
  c_char, c_byte,
  c_int, 
  c_short, c_long,
  c_float, c_double,
  c_void;

extern jclass c_Boolean, 
  c_Char, c_Byte, 
  c_Integer, c_Short,
  c_Long, c_Float,
  c_Class, c_Field, c_Method, c_Selector,
  c_Object, c_String, 
  c_Double, c_PhaseCImpl, c_Primitives,
  c_SwarmEnvironment, c_Collection,
  c_Modifier;

extern jmethodID m_BooleanValueOf,
  m_ByteValueOf, 
  m_IntegerValueOf, 
  m_ShortValueOf, m_LongValueOf,   
  m_FloatValueOf, m_DoubleValueOf, 
  m_StringValueOfBoolean, 
  m_StringValueOfChar,
  m_StringValueOfInt,
  m_StringValueOfLong,
  m_StringValueOfFloat,
  m_StringValueOfDouble,
  m_StringValueOfObject,
  m_FieldSet, m_FieldSetChar,
  m_ClassGetDeclaredField,
  m_ClassGetDeclaredFields,
  m_ClassGetDeclaredMethods,
  m_ClassGetFields,
  m_ClassGetName,
  m_ClassIsArray,
  m_FieldGetType,
  m_FieldGetBoolean,
  m_FieldGetChar,
  m_FieldGetShort,
  m_FieldGetInt,
  m_FieldGetLong,
  m_FieldGetFloat,
  m_FieldGetDouble,
  m_FieldGetObject,
  m_FieldGetName,
  m_MethodGetName,
  m_MethodGetReturnType,
  m_MethodGetModifiers,
  m_ModifierIsPublic,
  m_ModifierIsStatic,
  m_SelectorConstructor,
  m_HashCode,
  m_Equals,
  m_PhaseCImpl_copy_creating_phase_to_using_phase,
  m_PrimitivesGetTypeMethod;

extern jfieldID f_nameFid,
  f_retTypeFid,
  f_argTypesFid,
  f_typeSignatureFid,
  f_objcFlagFid,
  f_nextPhase;
