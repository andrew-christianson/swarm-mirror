// Swarm library. Copyright � 1999-2000 Swarm Development Group.
// This library is distributed without any warranty; without even the
// implied warranty of merchantability or fitness for a particular purpose.
// See file LICENSE for details and terms of copying.

#import <swarm.h> // initSwarm
#include <swarmconfig.h> // HAVE_KAFFE
#import "../../src/defobj/java.h" 

void
swarm_java_constructors ()
{
#ifdef hpux
  {
#ifdef HAVE_KAFFE
    extern void libkaffeswarmstubs_constructor (void);
    extern void libkaffeswarm_constructor (void);

    libkaffeswarmstubs_constructor ();
    libkaffeswarm_constructor ();
#else
    extern void libjavaswarmstubs_constructor (void);
    extern void libjavaswarm_constructor (void);

    libjavaswarmstubs_constructor ();
    libjavaswarm_constructor ();
#endif
  }
#endif
}


JNIEXPORT void JNICALL
Java_swarm_SwarmEnvironmentImpl_initSwarm (JNIEnv *env,
                                           jobject obj,
                                           jstring appName,
                                           jstring version,
                                           jstring bugAddress,
                                           jobjectArray args)
{
  JNIEXPORT void JNICALL Java_swarm_SwarmEnvironmentImpl__initSwarm___Ljava_lang_String_2Ljava_lang_String_2Ljava_lang_String_2_3Ljava_lang_String_2 (JNIEnv *env, jobject obj, jstring appName, jstring version, jstring bugAddress, jobjectArray args);

  Java_swarm_SwarmEnvironmentImpl__initSwarm___Ljava_lang_String_2Ljava_lang_String_2Ljava_lang_String_2_3Ljava_lang_String_2 (env, obj, appName, version, bugAddress, args);

  swarm_directory_java_associate_objects (obj);
}
