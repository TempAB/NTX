# Schema Mods



lets prepare for a new project. 

1- while updating the esp32 recently, the following message came up in the log:

Updating /config/esphome/roof-wind-system.yaml
INFO ESPHome 2025.10.3
INFO Reading configuration /config/esphome/roof-wind-system.yaml...
INFO Updating https://github.com/txubelaxu/esphome-jk-bms.git@main
WARNING Using switch.SWITCH_SCHEMA is deprecated and will be removed in ESPHome 2025.11.0. Please use switch.switch_schema(...) instead. If you are seeing this, report an issue to the external_component author and ask them to update it. https://developers.esphome.io/blog/2025/05/14/_schema-deprecations/. Component using this schema: jk_rs485_bms
WARNING Using switch.SWITCH_SCHEMA is deprecated and will be removed in ESPHome 2025.11.0. Please use switch.switch_schema(...) instead. If you are seeing this, report an issue to the external_component author and ask them to update it. https://developers.esphome.io/blog/2025/05/14/_schema-deprecations/. Component using this schema: jk_rs485_bms ............ 

( note that there were many more of this same repeated message, i just copied the first few for your review) . 


2 - the text in the link called out in the log above is copied below for your review: 

In order to align all of the top level platform components (listed below), we are deprecating the *_SCHEMA constants that are present. Some examples are SENSOR_SCHEMA, SWITCH_SCHEMA and so on.
Each entity platform component has a matching *_schema(...) function which takes the class type and common schema defaults as arguments. There are plenty of examples in the ESPHome codebase of these.
This will become a breaking change in ESPHome 2025.11.0, set to release around the 19th of November 2025. The breaking PRs will be merged right after the 2025.10.0 release goes out around the 15th of October 2025.
If you are a maintainer of external_components that use these constants, please update them to use the new *_schema(...) functions. If you are a user of external_components and see the warning in your install logs, please reach out to the maintainers of those components and ask them to update their code.
external_components are able to import the ESPHome version into their python file in order to support older versions in the cases where the relevant *_schema(...) function was not added yet.
List of affected components
alarm_control_panel
binary_sensor
button
climate
cover
datetime
event
fan
lock
media_player
number
select
sensor
switch
text
text_sensor
update
valve.              


3- copied below is someones example for how they addressed the new code change:      

Here's a concrete example of how the ratgdo external component handled a recent breaking change when ESPHome moved from COVER_SCHEMA to cover_schema():
Before (old pattern):
CONFIG_SCHEMA = cover.COVER_SCHEMA.extend(
{
cv.GenerateID(): cv.declare_id(RATGDOCover),
cv.Optional(CONF_ON_OPENING): automation.validate_automation(
{cv.GenerateID(CONF_TRIGGER_ID): cv.declare_id(CoverOpeningTrigger)}
),
# ... other config options
}
).extend(RATGDO_CLIENT_SCHEMA)
After (new pattern):
CONFIG_SCHEMA = (
cover.cover_schema(RATGDOCover) # Changed from COVER_SCHEMA to cover_schema()
.extend(
{
cv.Optional(CONF_ON_OPENING): automation.validate_automation(
{cv.GenerateID(CONF_TRIGGER_ID): cv.declare_id(CoverOpeningTrigger)}
),
# ... other config options
}
)
.extend(RATGDO_CLIENT_SCHEMA)
)
This pattern applies to other component types too:
sensor.SENSOR_SCHEMA → sensor.sensor_schema(MySensor)
binary_sensor.BINARY_SENSOR_SCHEMA → binary_sensor.binary_sensor_schema(MyBinarySensor)
switch.SWITCH_SCHEMA → switch.switch_schema(MySwitch)
light.LIGHT_SCHEMA → light.light_schema(MyLight) (not yet rolled out)
The key change is that the new functions take your component class as a parameter, but otherwise the structure remains the same. 

4- copied below is another example of someone fixing code direclty related to this project: 

Find below Python code from file located at: components/jk_rs485_bms/switch/init.py that has been modified per the link above to accommodate the schema deprication update needed.:

import esphome.codegen as cg
from esphome.components import switch
import esphome.config_validation as cv
from esphome.const import CONF_ICON, CONF_ID
from .. import CONF_JK_RS485_BMS_ID, JK_RS485_BMS_COMPONENT_SCHEMA, jk_rs485_bms_ns
from ..const import (
CONF_BALANCING, CONF_PRECHARGING, CONF_CHARGING, CONF_DISCHARGING, CONF_DISPLAY_ALWAYS_ON, CONF_EMERGENCY, CONF_HEATING, CONF_CHARGING_FLOAT_MODE,
CONF_SMART_SLEEP_ON, CONF_DISABLE_PCL_MODULE,CONF_DISABLE_TEMPERATURE_SENSORS, CONF_TIMED_STORED_DATA,
CONF_GPS_HEARTBEAT,CONF_PORT_SELECTION,CONF_SPECIAL_CHARGER
)
DEPENDENCIES = ["jk_rs485_bms"]
CODEOWNERS = ["@syssi","@txubelaxu"]
ICON_CHARGING = "mdi:battery-charging-50"
ICON_DISCHARGING = "mdi:battery-charging-50"
ICON_BALANCING = "mdi:seesaw"
ICON_EMERGENCY = "mdi:exit-run"
ICON_HEATING = "mdi:radiator"
ICON_DISABLE_TEMPERATURE_SENSORS = "mdi:thermometer-off"
ICON_SMART_SLEEP_ON = "mdi:sleep"
ICON_TIMED_STORED_DATA = "mdi:calendar-clock"
ICON_DISABLE_PCL_MODULE = "mdi:power-plug-off"
ICON_CHARGING_FLOAT_MODE = "mdi:battery-charging-80"
ICON_DISPLAY_ALWAYS_ON = "mdi:television"
SWITCHES = {
CONF_CHARGING: [0x0070,0x10,0x04], #0x1000 -> 0x0078
CONF_DISCHARGING: [0x0074,0x10,0x04], #02.10.10.78.00.02. 04. 00.00.00.00.37.A9
CONF_BALANCING: [0x0078,0x10,0x04], #02.10.10.78.00.02. 04. 00.00.00.01.F6.69.
CONF_HEATING:                             [0x0014,0x11,0x02],  
CONF_DISABLE_TEMPERATURE_SENSORS:         [0x0014,0x11,0x02],     #0x1000 -> 0x0114
CONF_GPS_HEARTBEAT:                       [0x0014,0x11,0x02],                   #DISPLAY ALWAYS ON  (0x0114)
CONF_PORT_SELECTION:                      [0x0014,0x11,0x02],                  #02.10.11.14.00.01.   02.  02.00.   B1.D5.   OFF
CONF_DISPLAY_ALWAYS_ON:                   [0x0014,0x11,0x02],               #02.10.11.14.00.01.   02.  02.10.   B0.19.   ON   0000 0010 0001 0000
CONF_SPECIAL_CHARGER:                     [0x0014,0x11,0x02],                  #SMART SLEEP ON
CONF_SMART_SLEEP_ON:                      [0x0014,0x11,0x02],                  #02.10.11.14.00.01.   02.  00.10.   B1.79.
CONF_DISABLE_PCL_MODULE:                  [0x0014,0x11,0x02],              
CONF_TIMED_STORED_DATA:                   [0x0014,0x11,0x02],              
CONF_CHARGING_FLOAT_MODE:                 [0x0014,0x11,0x02],             #02.10.11.14.00.01.   02.  02.10.   B0.19.

CONF_PRECHARGING:                         [0x0000,0x00,0x00],                     #02.10.10.84.00.02.04.00.00.0D.70.3D.CC.
CONF_EMERGENCY:                           [0x0000,0x00,0x00],
}
JkRS485BmsSwitch = jk_rs485_bms_ns.class_("JkRS485BmsSwitch", switch.Switch, cg.Component)
CONFIG_SCHEMA = JK_RS485_BMS_COMPONENT_SCHEMA.extend(
{
cv.Optional(CONF_PRECHARGING): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_CHARGING): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_CHARGING): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_CHARGING): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_DISCHARGING): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_DISCHARGING): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_BALANCING): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_BALANCING): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_EMERGENCY): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_EMERGENCY): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_HEATING): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_HEATING): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_DISABLE_TEMPERATURE_SENSORS): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_DISABLE_TEMPERATURE_SENSORS): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_DISPLAY_ALWAYS_ON): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_DISPLAY_ALWAYS_ON): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_SMART_SLEEP_ON): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_SMART_SLEEP_ON): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_TIMED_STORED_DATA): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_TIMED_STORED_DATA): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_CHARGING_FLOAT_MODE): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_CHARGING_FLOAT_MODE): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_DISABLE_PCL_MODULE): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_DISABLE_PCL_MODULE): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_GPS_HEARTBEAT): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_DISABLE_PCL_MODULE): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_PORT_SELECTION): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_DISABLE_PCL_MODULE): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
cv.Optional(CONF_SPECIAL_CHARGER): (
switch.switch_schema(JkRS485BmsSwitch)
.extend(
{
cv.Optional(CONF_ICON, default=ICON_DISABLE_PCL_MODULE): cv.icon,
}
)
.extend(cv.COMPONENT_SCHEMA)
),
}
)
async def to_code(config):
hub = await cg.get_variable(config[CONF_JK_RS485_BMS_ID])
for key, param_config in SWITCHES.items():
if key in config:
conf = config[key]
var = cg.new_Pvariable(conf[CONF_ID])
await cg.register_component(var, conf)
await switch.register_switch(var, conf)
cg.add(getattr(hub, f"set_{key}_switch")(var))
cg.add(var.set_parent(hub))
cg.add(var.set_register_address(param_config[0]))
cg.add(var.set_third_element_of_frame(param_config[1]))
cg.add(var.set_data_length(param_config[2]))


REQUEST: please take a look at the erro listing request for code changes due to the upcoming deprications, the responses, perform a complete review of the component files in this project folder to determine the scope of impact of this schema deprecation requested change and let me know what you find. please advise your plan as guided by the agents file. lets review your findings before making any code changes.

