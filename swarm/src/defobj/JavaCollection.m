#import <defobj/directory.h>
#import <defobj/defalloc.h>
#import <defobj/FCall.h>
#import <collections.h> // Member, End
#import <defobj/JavaCollection.h>
#import <defobj/JavaProxy.h>

@implementation JavaCollection

- (BOOL)isJavaProxy
{
  return YES;
}

- (unsigned)getCount
{
  jobject coll = SD_FINDJAVA (jniEnv, self);
  jclass class;
  jmethodID method;

  if (!(class = (*jniEnv)->GetObjectClass (jniEnv, coll)))
    abort ();

  if (!(method =
	(*jniEnv)->GetMethodID (jniEnv,
				class,
				"size",
				"()I")))
    abort ();
  (*jniEnv)->DeleteLocalRef (jniEnv, class);
  return (*jniEnv)->CallIntMethod (jniEnv, coll, method);
}

- begin: aZone
{
  jobject coll = SD_FINDJAVA (jniEnv, self);
  jclass class;
  jmethodID method;
  jobject iterator;
  DirectoryEntry *entry;

  if (!(class = (*jniEnv)->GetObjectClass (jniEnv, coll)))
    abort ();

  if (!(method =
	(*jniEnv)->GetMethodID (jniEnv,
				class,
				"iterator",
				"()Ljava/util/Iterator;")))
    abort ();
  (*jniEnv)->DeleteLocalRef (jniEnv, class);
  iterator = (*jniEnv)->CallObjectMethod (jniEnv, coll, method);
  entry = SD_ADD (jniEnv, iterator, [JavaProxy create: aZone]);
  (*jniEnv)->DeleteLocalRef (jniEnv, iterator);
  return entry->object;
}

- (id <Symbol>)getLoc
{
  jobject iterator = SD_FINDJAVA (jniEnv, self);
  jclass class;
  jmethodID method;

  if (!(class = (*jniEnv)->GetObjectClass (jniEnv, iterator)))
    abort (); 
  if (!(method =
	(*jniEnv)->GetMethodID (jniEnv,
				class,
				"hasNext",
				"()Z")))
    abort ();
  (*jniEnv)->DeleteLocalRef (jniEnv, class);
  return ((*jniEnv)->CallBooleanMethod (jniEnv, iterator, method) == JNI_TRUE
	  ? Member
	  : End);
}

- next
{
  jobject iterator = SD_FINDJAVA (jniEnv, self);
  jobject item;
  id proxy;
  jclass class;
  jmethodID method;

  if (!(class = (*jniEnv)->GetObjectClass (jniEnv, iterator)))
    abort ();
  if (!(method =
	(*jniEnv)->GetMethodID (jniEnv,
				class,
				"next",
				"()Ljava/lang/Object;")))
    abort ();
  (*jniEnv)->DeleteLocalRef (jniEnv, class);
  item = (*jniEnv)->CallObjectMethod (jniEnv, iterator, method);
  proxy = SD_ENSUREOBJC (jniEnv, item);
  (*jniEnv)->DeleteLocalRef (jniEnv, item);
  return proxy;
}


- getFirst
{
  jobject coll = SD_FINDJAVA (jniEnv, self);
  jclass class = (*jniEnv)->GetObjectClass (jniEnv, coll);
  jobject first;
  jmethodID method;
  id ret;

  if (!(method =
	(*jniEnv)->GetMethodID (jniEnv,
				class,
				"get",
				"(I)Ljava/lang/Object;")))
    abort ();
  (*jniEnv)->DeleteLocalRef (jniEnv, class);
  first = (*jniEnv)->CallObjectMethod (jniEnv, coll, method, 0);
  ret = SD_ENSUREOBJC (jniEnv, first);
  (*jniEnv)->DeleteLocalRef (jniEnv, first);
  return ret;
}

- (void)forEach: (SEL)sel :arg1
{
  id <FCall> call;
  id <FArguments> arguments =
    [FArguments createBegin: getZone (self)];
  jobject jsel = SD_FINDJAVA (jniEnv, (id) sel);
  jobject coll = SD_FINDJAVA (jniEnv, self);
  const char *sig =
    swarm_directory_ensure_selector_type_signature (jniEnv, jsel);
  jobject javaTarget;
  jsize i, size;
  jclass class;
  jmethodID method;
  char *selname, *ptr;

  if (!(class = (*jniEnv)->GetObjectClass (jniEnv, coll)))
    abort ();
  
  [arguments setJavaSignature: sig];
  [arguments setObjCReturnType: _C_ID];
  [arguments addObject: arg1];
  arguments = [arguments createEnd];

  call = [FCall createBegin: getZone (self)];
  [call setArguments: arguments];

  if (!(method =
	(*jniEnv)->GetMethodID (jniEnv,
				class,
				"size",
				"()I")))
    abort ();
  size = (*jniEnv)->CallIntMethod (jniEnv, coll, method);
  if (!(method =
	(*jniEnv)->GetMethodID (jniEnv,
				class,
				"get",
				"(I)Ljava/lang/Object;")))
    abort ();
  (*jniEnv)->DeleteLocalRef (jniEnv, class);
  javaTarget = (*jniEnv)->CallObjectMethod (jniEnv, coll, method, 0);
  selname = SSTRDUP (sel_get_name (sel));
  ptr = strchr (selname, ':');
  *ptr = '\0';
  [call setJavaMethod: selname inObject: javaTarget];
  call = [call createEnd];
  [call performCall];
  (*jniEnv)->DeleteLocalRef (jniEnv, javaTarget);
  for (i = 1; i < size; i++)
    {
      javaTarget = (*jniEnv)->CallObjectMethod (jniEnv, coll, method, i);
      updateJavaTarget (call, javaTarget);
      [call performCall];
      (*jniEnv)->DeleteLocalRef (jniEnv, javaTarget);
    }
  [call drop]; 
  [arguments drop];
  [scratchZone free: (void *) selname];
  [scratchZone free: (void *) sig];
}

- (BOOL)allSameClass
{
  id index, member;
  BOOL ret = YES;
  jclass firstJavaClass;

  index = [(id) self begin: scratchZone];
  member = [index next];
  
  if (member)
    {
      jobject firstJavaObject = SD_FINDJAVA (jniEnv, member);
      
      firstJavaClass = (*jniEnv)->GetObjectClass (jniEnv, firstJavaObject);
    }
  else
    firstJavaClass = (jclass) 0;
    
  for (member = [index next];
       [index getLoc] == Member;
       member = [index next])
    if (!member)
      {
        if (firstJavaClass)
          {
            ret = NO;
            break;
          }
      }
    else
      {
        jobject javaObject = SD_FINDJAVA (jniEnv, member);
        jclass javaClass = (*jniEnv)->GetObjectClass (jniEnv, javaObject);

        ret = (((*jniEnv)->IsSameObject (jniEnv, javaClass, firstJavaClass)
                == JNI_TRUE)
               ? YES
               : NO);
        (*jniEnv)->DeleteLocalRef (jniEnv, javaClass);
        if (ret == NO)
          break;
      }
  (*jniEnv)->DeleteLocalRef (jniEnv, firstJavaClass);
  [index drop];
  return ret;
}

@end
