//
//  main.m
//  �PROJECTNAME�
//
//  Created by �FULLUSERNAME� on �DATE�.
//  Copyright �ORGANIZATIONNAME� �YEAR�. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Swarm/simtools.h>     // initSwarm () and swarmGUIMode

int main(int argc, const char *argv[])
{
	// Swarm initialization: all Swarm apps must call this first.
	initSwarm (argc, argv);

    return NSApplicationMain(argc,  (const char **) argv);
}
