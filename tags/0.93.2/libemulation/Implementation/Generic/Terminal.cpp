
/**
 * libemulation
 * Terminal
 * (C) 2011 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls a terminal.
 */

#include "Terminal.h"

#include "Emulation.h"

Terminal::Terminal()
{
	emulation = NULL;
	
	canvas = NULL;
}

bool Terminal::setRef(string name, OEComponent *ref)
{
	if (name == "emulation")
	{
		if (emulation)
			emulation->postMessage(this,
								   EMULATION_DESTROY_CANVAS,
								   &canvas);
		emulation = ref;
		if (emulation)
			emulation->postMessage(this,
								   EMULATION_CREATE_CANVAS,
								   &canvas);
	}
	else
		return false;
	
	return true;
}
