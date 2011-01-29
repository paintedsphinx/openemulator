
/**
 * libemulation
 * Apple Graphics Tablet
 * (C) 2010-2011 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls an Apple Graphics Tablet.
 */

#include "AppleGraphicsTablet.h"

#include "CompositeMonitor.h"
#include "Emulation.h"
#include "CanvasInterface.h"

AppleGraphicsTablet::AppleGraphicsTablet()
{
	emulation = NULL;
	canvas = NULL;
}

bool AppleGraphicsTablet::setValue(string name, string value)
{
	if (name == "viewPath")
		viewPath = value;
	else
		return false;
	
	return true;
}

bool AppleGraphicsTablet::setRef(string name, OEComponent *ref)
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

bool AppleGraphicsTablet::init()
{
	if (!emulation)
	{
		log("property 'emulation' undefined");
		return false;
	}
	
	if (!canvas)
	{
		log("canvas could not be created");
		return false;
	}
	
	if (canvas)
	{
		OEImage frame;
		frame.readFile(viewPath);
		canvas->postMessage(this, CANVAS_POST_FRAME, &frame);
		
		CanvasConfiguration configuration;
		configuration.viewMode = CANVAS_VIEWMODE_FIT_CANVAS;
		configuration.captureMode = CANVAS_CAPTUREMODE_NO_CAPTURE;
		configuration.defaultViewSize = frame.getSize();
		configuration.canvasSize = frame.getSize();
		configuration.contentRect = OEMakeRect(0, 0, 1, 1);
		canvas->postMessage(this, CANVAS_CONFIGURE, &configuration);
	}
	
	return true;
}
