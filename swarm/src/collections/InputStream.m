// Swarm library. Copyright � 1996-1999 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

/*
Name:         InputStream.m
Description:  character string object   
Library:      collections
*/

#import <collections.h>
#import <collections/StringObject.h> // setLiteralFlag:
#import <collections/OutputStream.h>
#import <collections/InputStream.h>
#import <defobj/defalloc.h> // getZone
#include <objc/objc-api.h> // type definitions
#include <misc.h> // errno, fputs, isDigit, isSpace
#include <collections/predicates.h>
#import "../defobj/internal.h" // lisp_process_array, size_for_objc_type

@implementation InputStream_c

PHASE(Creating)

+ createBegin: aZone
{
  InputStream_c *newStream = [aZone allocIVars: self];
  return newStream;
}

- (void)setFileStream: (FILE *)file
{
  fileStream = file;
}

- createEnd
{
  createByCopy ();
  setNextPhase (self);
  return self;
}

+ create: aZone setFileStream: (FILE *)file
{
  InputStream_c *newStream;

  newStream = [aZone allocIVars: getNextPhase (self)];
  newStream->fileStream = file;
  return newStream;
}

PHASE(Using)

- (FILE *)getFileStream
{
  return fileStream;
}

static id
readString (id inStream, char terminator)
{
  int c;
  id string;
  FILE *fp = [inStream getFileStream];
  char buf[2];

  string = [String createBegin: [inStream getZone]];
  [string setC: ""];
  [string setLiteralFlag: terminator ? YES: NO];
  string = [string createEnd];
  
  buf[1] = '\0';
  while ((c = fgetc (fp)) != EOF
         && !(terminator
              ? c == terminator
              : (isSpace (c) || c == '(' || c == ')')))
    {
      buf[0] = c;
      [string catC: buf];
    }
  if (c == EOF)
    {
      [string drop];
      return nil;
    }
  else if (!terminator)
    ungetc (c, fp);
  return string;
}

- (void)_unexpectedEOF_
{
  raiseEvent (InvalidArgument, "unexpected EOF");
}

- (void)_badType_ : obj
{
  raiseEvent (InvalidArgument, "wrong type");
}
  
- getExpr
{
  int c;
  id aZone = getZone (self);
  
  while (((c = fgetc (fileStream)) != EOF) && isSpace (c));
  if (c == EOF)
    return nil;
  else if (c == '\'')
    return [[[ArchiverQuoted createBegin: aZone]
              setQuotedObject: [self getExpr]]
             createEnd];
  else if (c == ':')
    {
      id newObj = readString (self, '\0');
      
      if (newObj == nil)
        [self _unexpectedEOF_];
      
      return [[[ArchiverKeyword createBegin: aZone]
                setKeywordName: [newObj getC]]
               createEnd];
    }
  else if (c == '<')
    {
      id newObj = readString (self, '>');
      id value;
      
      if (newObj == nil)
	[self _unexpectedEOF_];
      
      value = [[[ArchiverValue createBegin: aZone]
		 setClass: objc_lookup_class ([newObj getC])]
		createEnd];
      [newObj drop];
      return value;
    }
  else if (c == '#')
    {
      int c2 = fgetc (fileStream);

      if (c2 == ':')
        {
          id newObj = readString (self, '\0');
          
          if (newObj == nil)
            [self _unexpectedEOF_];
          
          return [[[ArchiverKeyword createBegin: aZone]
                    setKeywordName: [newObj getC]]
                   createEnd];
        }
      else if (c2 >= '0' && c2 <= '9')
        {
          unsigned rank;

          ungetc (c2, fileStream);
          {
            int ret = fscanf (fileStream, "%u", &rank);
            
            if (ret != 1)
              raiseEvent (InvalidArgument,
                          "Unable to scan array dimensions [ret = %d]", ret);
          }
          
          {
            id newObj = [self getExpr];
            
            if (newObj == nil)
              [self _unexpectedEOF_];
            
            return [[[ArchiverArray createBegin: aZone]
                      setArray: newObj]
                     createEnd];
          }
        }
      else if (c2 == '\\')
        {
          unsigned val;
          unsigned char c3;

          c3 = fgetc (fileStream);

          if (c3 >= '0' && c3 <= '3')
            {
              int ret;

              ungetc (c3, fileStream);
              ret = fscanf (fileStream, "%o", &val);
              
              if (ret != 1)
                raiseEvent (InvalidArgument,
                            "Unable to scan octal character value");
              c3 = (unsigned char)val;
            }
          return [[[ArchiverValue createBegin: aZone]
                    setChar: c3] createEnd];
        }
      else if (c2 == 't' || c2 == 'f')
        return [[[ArchiverValue createBegin: aZone]
                  setBoolean: (c2 == 't')] createEnd];
      else
        raiseEvent (InvalidArgument, "Unknown `#' form");
    }
  else if (c == '(')
    {
      id list = [ArchiverList create: aZone];
      
      while (YES)
        {
          id newObj = [self getExpr];
          
          if (newObj == nil)
            [self _unexpectedEOF_];
          if (newObj == (id) ArchiverEOL)
            break;
          [list addLast: newObj];
        }

      if ([list getCount] == 3 && ARCHIVERDOTP ([list atOffset: 1]))
        {
          id pair = [ArchiverPair createBegin: aZone];
          
          [pair setCar: [list getFirst]];
          [pair setCdr: [list getLast]];
          [pair setConsFormatFlag: NO];
          pair = [pair createEnd];
          [list drop];
          return pair;
        }
      else if (quote_literal_p ([list getFirst]))
        {
          id quotedObject = [ArchiverQuoted createBegin: aZone];

          [quotedObject setQuotedObject: [list atOffset: 1]];
          [list drop];
          return [quotedObject createEnd];
        }
      else if (cons_literal_p ([list getFirst]))
        {
          id pair;
          
          if ([list getCount] != 3)
            raiseEvent (InvalidArgument, "cons accepts only two arguments");
          
          pair = [ArchiverPair createBegin: aZone];
          
          [pair setCar: [list atOffset: 1]];
          [pair setCdr: [list atOffset: 2]];
          [pair setConsFormatFlag: YES];
          pair = [pair createEnd];
          [list drop];
          return pair;
        }
      return list;
    }
  else if (c == ')')
    return ArchiverEOL;
  else if (c == '.')
    return ArchiverDot;
  else if (c == '"')
    {
      id string = readString (self, '"');

      if (string)
        return string;
      else
        [self _badType_ : string];
    }
  else if (c == ';')  // Lisp comment
    {
      while (YES)  // suck up the rest of line
        {
          c = fgetc (fileStream);
          if (c == '\n')            // end of comment (marked by end of line)
            return [self getExpr];  // re-commence search 
          else if (c == EOF)
            return nil;
        } 
    }
  else
    {
      id string;
      BOOL isNumeric = YES;
      char type = _C_LNG_LNG;

      ungetc (c, fileStream);
      string = readString (self, '\0');

      {
        const char *str = [string getC];
        size_t len = strlen (str);
        size_t pos;
        
        for (pos = 0; pos < len; pos++)
          {
            char ch = str[pos];
            
            if (ch == '.')
              type = _C_DBL;
            else if (!isDigit (ch) && !(pos == 0 && ch == '-'))
              {
                if (pos == len - 2)
                  {
                    if (ch == 'F')
                      type = _C_FLT;
                    else if (ch == 'D')
                      type = _C_DBL;
                    else if (ch == 'L')
                      type = _C_LNG_DBL;
                    else
                      {
                        isNumeric = NO;
                        break;
                      }
                  }
                else
                  {
                    isNumeric = NO;
                    break;
                  }
              }
          }
      
        if (isNumeric)
          {
            id number = [ArchiverValue createBegin: aZone];
            
            if (type == _C_LNG_DBL || type == _C_DBL || type == _C_FLT)
              {
                double val;
                
                errno = 0;
                val = strtod (str, NULL);
                if (errno != 0)
                  raiseEvent (InvalidArgument, "Could not convert to double");
                if (type == _C_FLT)
                  [number setFloat: (float) val];
                else if (type == _C_DBL)
                  [number setDouble: val];
                else if (type == _C_LNG_DBL)
                  [number setLongDouble: (long double) val];
                else
                  abort ();
              }
            else if (type == _C_LNG_LNG)
              {
                long long val;

                errno = 0;
                val = strtoll (str, NULL, 10);
                if (errno != 0)
                  raiseEvent (WarningMessage, "Could not convert to long");
                [number setLongLong: val];
              }
            else
              abort ();
            return [number createEnd];
          }
      }
      if (string)
        return string;
      else
        [self _badType_ : string];
    }
  raiseEvent (LoadError, "Unexpected character `%c'\n");
  return nil;
}

@end

@implementation ArchiverKeyword_c

PHASE(Creating)

- setKeywordName: (const char *)name
{
  keywordName = name;
  return self;
}

PHASE(Using)

- (const char *)getKeywordName
{
  return keywordName;
}

- lispOutShallow: (id <OutputStream>)stream
{
  return [self lispOutDeep: stream];
}

- lispOutDeep: (id <OutputStream>)stream
{
  [stream catC: "#:"];
  [stream catC: keywordName];
  return self;
}

@end
    
@implementation ArchiverArray_c

PHASE(Creating)

- setArray: array
{
  id <List> l;
  id proto;
  
  for (l = array, rank = 0; archiver_list_p (l); rank++)
    l = [l getFirst];

  proto = l;

  if (!valuep (proto))
    raiseEvent (InvalidArgument, "Array element not numeric");
  
  dims = [getZone (self) alloc: rank * sizeof (unsigned)];
  
  {
    unsigned dimnum;
    
    elementCount = 1;
    for (l = array, dimnum = 0; archiver_list_p (l); l = [l getFirst], dimnum++)
      {
        dims[dimnum] = [l getCount];
        elementCount *= dims[dimnum];
      }
  }

  {
    char *typebuf = [getZone (self) alloc: 2];
    
    typebuf[0] = [proto getValueType];
    typebuf[1] = '\0';
    type = typebuf;
  }
  elementSize = size_for_objc_type (type);
  {
    size_t size = elementCount * elementSize;

    data = [getZone (self) alloc: size];
    memset (data, 0, size);
  }
  
  {
    unsigned coord[rank];
    
    void expand (id val, unsigned dimnum)
      {
        if (archiver_list_p (val))
          {
            id <Index> li = [val begin: scratchZone];
            id item;
            unsigned pos = 0;
            
            while ((item = [li next]) != nil)
              {
                coord[dimnum] = pos;
                expand (item, dimnum + 1);
                pos++;
              }
            [li drop];
          }
        else
          {
            unsigned i;
            unsigned mult = 1;
            unsigned offset = 0;
            
            offset = coord[rank - 1];

            if (!valuep (val))
              raiseEvent (InvalidArgument, "Array element not a number");

            for (i = rank - 1; i > 0; i--)
              {
                mult *= dims[i];
                offset += coord[i - 1] * mult;
              }
            switch (*type)
              {
              case _C_ID:
                ((id *) data)[offset] = [val getObject];
                break;
	      case _C_CLASS:
		((Class *) data)[offset] = [val getClass];
		break;
              case _C_LNG_LNG:
                ((long long *) data)[offset] = [val getLongLong];
                break;
              case _C_FLT:
                ((float *) data)[offset] = [val getFloat];
                break;
              case _C_DBL:
                ((double *) data)[offset] = [val getDouble];
                break;
              case _C_LNG_DBL:
                ((long double *) data)[offset] = [val getLongDouble];
                break;
              case _C_UCHR:
                ((unsigned char *) data)[offset] = [val getChar];
                break;
              default:
                raiseEvent (InvalidArgument, "Unknown element type");
              }
          }
      }
    expand (array, 0);
  }
  return self;
}

PHASE(Using)

- (void *)getData
{
  return data;
}

- convertToType: (char)destType dest: (void *)ptr
{
  unsigned coord[rank];
  void permute (unsigned dim)
    {
      unsigned i;

      if (dim < rank)
        {
          for (i = 0; i < dims[dim]; i++)
            {
              coord[dim] = i;
              permute (dim + 1);
            }
        }
      else
        {
          unsigned offset = 0;
          unsigned mult = 1;
          long long val;
          
          offset = coord[rank - 1];
          for (i = rank - 1; i > 0; i--)
            {
              mult *= dims[i];
              offset += coord[i - 1] * mult;
            }
          val = ((long long *) data)[offset];
          switch (destType)
            {
            case _C_INT:
              ((int *) ptr)[offset] = (int) val;
              break;
            case _C_UINT:
              ((unsigned *) ptr)[offset] = (unsigned) val;
              break;
            case _C_LNG:
              ((long *) ptr)[offset] = (long) val;
              break;
            case _C_ULNG:
              ((unsigned long *) ptr)[offset] = (unsigned long) val;
              break;
            case _C_LNG_LNG:
              ((long long *) ptr)[offset] = (long long) val;
              break;
            case _C_ULNG_LNG:
              ((unsigned long long *) ptr)[offset] = (unsigned long long) val;
              break;
            case _C_SHT:
              ((short *) ptr)[offset] = (short) val;
              break;
            case _C_USHT:
              ((unsigned short *) ptr)[offset] = (unsigned short) val;
              break;
            default:
              abort ();
            }
        }
    }
  if (*type == _C_LNG_LNG)
    permute (0);
  else
    memcpy (ptr, data, size_for_objc_type (type) * elementCount);
  return self;
}

- (unsigned *)getDims
{
  return dims;
}

- (unsigned)getElementCount
{
  return elementCount;
}

- (size_t)getElementSize
{
  return elementSize;
}

- (char)getArrayType
{
  return *type;
}

- lispOutShallow: (id <OutputStream>)stream
{
  return [self lispOutDeep: stream];
}

- lispOutDeep: (id <OutputStream>)stream
{
  lisp_process_array (objc_type_for_array (type, rank, dims), 
                      data, data, stream, YES);
  return self;
}

- (void)drop
{
  [getZone (self) free: dims];
  [getZone (self) free: data];
  [getZone (self) free: (void *) type];
  [super drop];
}

@end

@implementation ArchiverValue_c
PHASE(Creating)
- setDouble: (double)val
{
  type = _C_DBL;
  value.d = val;
  return self;
}

- setLongDouble: (long double)val
{
  type = _C_LNG_DBL;
  value.ld = val;
  return self;
}

- setFloat: (float)val
{
  type = _C_FLT;
  value.f = val;
  return self;
}

- setLongLong: (long long)val
{
  type = _C_LNG_LNG;
  value.ll = val;
  return self;
}  

- setChar: (unsigned char)val
{
  type = _C_UCHR;
  value.ch = val;
  return self;
}  

- setBoolean: (BOOL)val
{
  type = _C_UCHR;
  value.ch = (unsigned char) val;
  return self;
}

- setNil
{
  type = _C_ID;
  value.obj = nil;
  return self;
}

- setClass: (Class)aClass
{
  type = _C_CLASS;
  value.class = aClass;
  return self;
}

PHASE(Using)

- (char)getValueType
{
  return type;
}

- (long double)getLongDouble
{
  return value.ld;
}

- (double)getDouble
{
  return value.d;
}

- (float)getFloat
{
  return value.f;
}

- (long long)getLongLong
{
  return value.ll;
}

- (int)getInteger
{
  if (type != _C_LNG_LNG)
    raiseEvent (InvalidArgument, "expecting an integer");
  return (int) value.ll;
}

- (unsigned)getUnsigned
{
  if (type != _C_LNG_LNG)
    raiseEvent (InvalidArgument, "expecting an integer");
  return (unsigned) value.ll;
}

- (unsigned char)getChar
{
  return value.ch;
}

- (BOOL)getBoolean
{
  return value.ch;
}

- getObject
{
  return value.obj;
}

- (Class)getClass
{
  return value.class;
}

- lispOutShallow: (id <OutputStream>)stream
{
  return [self lispOutDeep: stream];
}

- lispOutDeep: (id <OutputStream>)stream
{
  switch (type)
    {
    case _C_CHR:
    case _C_UCHR:
      [stream catChar: value.ch];
      break;
    case _C_DBL:
      [stream catDouble: value.d];
      break;
    case _C_LNG_DBL:
      [stream catLongDouble: value.ld];
      break;
    case _C_FLT:
      [stream catFloat: value.f];
      break;
    case _C_LNG_LNG:
      [stream catLongLong: value.ll];
      break;
    default:
      [stream catC: "serialization for this type not implemented yet"];
      break;
    }
  return self;
}

@end

@implementation ArchiverPair_c
PHASE(Creating)

- setCar: val;
{
  car = val;
  return self;
}

- setCdr: val
{
  cdr = val;
  return self;
}

- setConsFormatFlag: (BOOL)theConsFormatFlag
{
  consFormatFlag = theConsFormatFlag;
  return self;
}

PHASE(Using)
- getCar
{
  return car;
}

- getCdr
{
  return cdr;
}

- (BOOL)getConsFormatFlag
{
  return consFormatFlag;
}

- lispOutShallow: (id <OutputStream>)stream
{
  return [self lispOutDeep: stream];
}

- lispOutDeep: (id <OutputStream>)stream
{
  [stream catC: (consFormatFlag ? "(cons " : "(")];
  [car lispOutDeep: stream];
  [stream catC: (consFormatFlag ? " ": " . ")];
  [cdr lispOutDeep: stream];
  [stream catC: ")"];
  return self;
}
@end

@implementation ArchiverList_c
PHASE(Creating)
PHASE(Using)
- lispOutShallow: (id <OutputStream>)stream
{
  [self lispOutDeep: stream];
  return self;
}

- lispOutDeep: (id <OutputStream>)stream
{
  id index = [self begin: getZone (self)];
  id member;

  [stream catC: "("];

  // get the first member of the list
  member = [index next];

  if (list_literal_p (member))
    [stream catC: [member getC]];
  else if (cons_literal_p (member))
    [stream catC: [member getC]];
  else if (stringp (member))
    {
      const char *funcName = [member getC];

      if (strcmp (funcName, MAKE_INSTANCE_FUNCTION_NAME) == 0
          || strcmp (funcName, MAKE_CLASS_FUNCTION_NAME) == 0) 
         {
           [stream catC: [member getC]];
           member = [index next];
           [stream catC: " "];
           [member lispOutDeep: stream];
         }
      else if (strcmp (funcName, PARSE_FUNCTION_NAME) == 0)
        [stream catC: [member getC]];        
      else
        raiseEvent (InvalidArgument, "function not one of ",
                    MAKE_INSTANCE_FUNCTION_NAME
                    " or "
                    MAKE_CLASS_FUNCTION_NAME
                    " or "
                    PARSE_FUNCTION_NAME);
    }
  else
    [member lispOutDeep: stream];
  
  for (member = [index next]; [index getLoc] == Member; member = [index next])
    {
      [stream catC: " "];
      if (member == (id) ArchiverEOL)
        break;
      else if (keywordp (member)
               || valuep (member)
               || arrayp (member)
               || pairp (member)
               || quotedp (member)
               || stringp (member)
               || archiver_list_p (member))
        [member lispOutDeep: stream];
      else
        raiseEvent (InvalidArgument, "expression type not supported");
    }
  [stream catC: ")"];
  [index drop];
  return self;
}
@end

@implementation ArchiverQuoted_c
PHASE(Creating)
- setQuotedObject: aValue
{
  value = aValue;
  return self;
}

PHASE(Using)
- getQuotedObject
{
  return value;
}

- lispOutDeep: (id <OutputStream>)stream
{
  [stream catC: "'"];
  if (stringp (value))
    [stream catC: [value getC]];
  else
    [value lispOutDeep: stream];
  return self;
}
@end