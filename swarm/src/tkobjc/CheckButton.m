// Swarm library. Copyright � 1996-2000 Swarm Development Group.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#import <tkobjc/global.h>
#import <tkobjc/CheckButton.h>

inline int
stringIsFalse (const char *s)
{
  return s[0] == '0' && s[1] == '\0';
}

@implementation CheckButton

PHASE(Creating)

- createEnd
{
  [super createEnd];
  
  // create the checkbutton
  [globalTkInterp eval: "checkbutton %s;", widgetName];
  [globalTkInterp eval: "%s configure -variable %s;",
                  widgetName,
		  variableName];
  return self;
}

PHASE(Using)

- (void)setBoolValue: (BOOL)v
{
  if (v)
    [globalTkInterp eval: "%s select;", widgetName];
  else
    [globalTkInterp eval: "%s deselect;", widgetName];
}

- (const char *)getValue
{
  return [globalTkInterp variableValue: variableName];
}

- (void)setValue: (const char *)v
{
  [self setBoolValue: stringIsFalse (v)];
}


// just ignore this entirely - does it mean anything?
- setWidth: (unsigned)w Height: (unsigned)h
{
  return self;
}

- (BOOL)getBoolValue
{
  return !stringIsFalse ([self getValue]);
}
@end
