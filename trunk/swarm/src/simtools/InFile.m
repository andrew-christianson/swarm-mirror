// Swarm library. Copyright (C) 1996-1997 Santa Fe Institute.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#define __USE_FIXED_PROTOTYPES__  // for gcc headers
#import <stdio.h>
#import <simtools/InFile.h>
#import <collections/String.h>

@implementation InFile

+ create: aZone withName: (const char *)theName
{
  FILE *aFile;
  id anObj;

  aFile = fopen (theName,"r");
  if (aFile == NULL)
    {
      fprintf (stderr,
               "Unable to open %s as an InFile object!\n",
               theName);
      return nil;
    }
  
  anObj = [InFile create: aZone];
  [anObj _setFile_: aFile];
  
  return anObj;
}

- _setFile_: (FILE *) aFile
{
  theFile = aFile;
  return self;
}

- (int)getWord: (char *)aWord
{
  return fscanf (theFile,"%s",aWord) != EOF;
}

- (int)getLine: (char *)aLine 
{
  int c, pos = 0;
  
  while ((c = fgetc (theFile)) != EOF && (c == ' ' || c == '\t'));

  while (c != EOF && c != '\n')
    {
      aLine[pos++] = c;
      c = fgetc (theFile);
    }
  aLine[pos] = '\0';
  if (c == EOF)
    return 0;
  else
    {
      ungetc ('\n', theFile);
      return 1;
    }
}

- (int)getInt: (int *) anInt
{
  return fscanf (theFile, "%d", anInt) != EOF;
}

- (int)getUnsigned: (unsigned *)anUnsigned
{
  return fscanf (theFile, "%u", anUnsigned) != EOF;
}

- (int)getLong: (long *)aLong
{
  return fscanf (theFile, "%ld", aLong) != EOF;
}

- (int)getUnsignedLong: (unsigned long *)anUnsLong
{
  return fscanf (theFile, "%lu", anUnsLong) != EOF;
}

-(int) getDouble: (double *)aDouble
{
  return fscanf (theFile, "%lg", aDouble) != EOF;
}

- (int)getFloat: (float *)aFloat
{
  return fscanf (theFile, "%g", aFloat) != EOF;
}

- (int)getChar: (char *)aChar
{
  *aChar = fgetc(theFile);
  return ((*aChar) != EOF);
}

- (int)unGetChar: (char)aChar
{
  return ungetc (aChar, theFile) != EOF;
}

- (int)skipLine
{
  char aChar;
  
  while (1)
    {
      aChar = fgetc(theFile);

      if(aChar == EOF)
        return 0;
      if(aChar == '\n')
        return 1;
    }
}

- (void)drop
{
  fclose (theFile);
  [super drop];
}

@end
