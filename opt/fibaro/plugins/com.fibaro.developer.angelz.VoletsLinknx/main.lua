-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Name: VoletsLinknx
-- Type: Plugin
-- Version:	1.0.0 beta
-- Release date: 20-10-2014
-- Author: Fabrice Bernardi
-------------------------------------------------------------------------------------------

--! includes
require('VoletsLinknx')
require('UIActions')

--! Creates handler for VoletsLinknx (located in VoletsLinknx.lua file) class.
VoletsLinknx = VoletsLinknx(plugin.mainDeviceId)

--! Array that contains functions assigned to user interface elements
-- in view tab.
uiBinding = {
--    ["Key_up"] = function() VoletsLinknx:Volet_up("up") end,
--   ["Key_down"] = function() VoletsLinknx:Volet_down() end
   ["Key_up"] = function() VoletsLinknx:set_val_knx(0) end,
   ["Key_down"] = function() VoletsLinknx:set_val_knx(100) end,
   ["slide_volet"] = function(eventArgs) VoletsLinknx:set_val_knx(eventArgs.values[1]) end
}

uiActions = UIActions({
	normalBinding = uiBinding
})

--! This function is usually used for handling an event assigned to
-- the elements (button, select, etc.) at "Advanced" tab.
-- However this function may be called via any http client by
-- constructing a request as described here.
-- Users of our system may also call such function for example by scenes.
-- Let us assume that we have PhilipsHue plugin,
-- which is able to switch off Philips light.
-- Plugin contains a method: switchOff(LightID).
-- Scene developer may call function switchOff(LightID)
-- by sending the POST request:
-- POST api/devices/DEVICE_ID/action/ACTION_NAME {"args":["arg1", ..., "argN"]}
function onAction(deviceId, action)
    VoletsLinknx:callAction(action.actionName, unpack(action.args))
end

--! Function that is usually used for handling an event assigned to one
-- of the handlers (button, select, switch, etc.) at "General" tab.
function onUIEvent(deviceId, event)
    uiActions:onUIEvent(deviceId, event)
end

-- This function is used for handling "Save" event performed by the user 
-- at plugin's "General" tab. Generally, it's applied to make sure that all
-- plugin properties are in line with our requirements.
--  Otherwise we can react for such a situation by changing the property value.
function configure(deviceId, config)
    plugin.restart()
end