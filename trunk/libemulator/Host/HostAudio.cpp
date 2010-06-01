
/**
 * libemulator
 * Host Audio
 * (C) 2010 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls host audio events
 */

#include "HostAudio.h"

bool HostAudio::setProperty(const string &name, const string &value)
{
	if (name == "runTime")
		runTime = getFloat(value);
	else if (name == "power")
		isPaused = getInt(value);
	else if (name == "notes")
		;
	else
		return false;
	
	return true;
}

bool HostAudio::getProperty(const string &name, string &value)
{
	if (name == "runTime")
		value = runTime;
	else if (name == "isPaused")
		value = isPaused;
	else
		return false;
	
	return true;
}

int HostAudio::ioctl(int message, void *data)
{
	switch (message)
	{
		case HOSTAUDIO_RENDERBUFFER:
		{
			postNotification(HOSTAUDIO_RENDER_WILL_START, data);
			postNotification(HOSTAUDIO_RENDER_DID_START, data);
			postNotification(HOSTAUDIO_RENDER_WILL_END, data);
			postNotification(HOSTAUDIO_RENDER_DID_END, data);
			
			return true;
		}
		case HOSTAUDIO_ADD_RUNTIME:
		{
			runTime += *((double *) data);
			return true;
		}
		case HOSTAUDIO_GET_RUNTIME:
		{
			*((double *) data) = runTime;
			return true;
		}
	}
	
	return false;
}