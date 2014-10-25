-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Name: VoletsLinknx
-- Type: Plugin
-- Version:	1.0.0 beta
-- Release date: 20-10-2014
-- Author: Fabrice Bernardi
-------------------------------------------------------------------------------------------

--! includes
require('common.device')
require('net.HTTPClient')

class 'VoletsLinknx' (Device)
local ip_hc2
--! Initializes Free SMS Service (VoletsLinknx class) plugin object.
--@param id: Id of the device.
function VoletsLinknx:__init(id)
    Device.__init(self, id)
    self.http = net.HTTPClient({ timeout = 10000 })
    self:test_prop()
end


function VoletsLinknx:test_prop()
  local configured = false
  
  local ip_nodejs = self.properties.ip_nodejs
  local port_nodejs = self.properties.port_nodejs
  local id_linknx = self.properties.id_linknx
 

  if(ip_nodejs == '') then
    configured = false
  else
    configured = true
  end
  
  if(port_nodejs == '') then
    configured = false
  else
    configured = true
  end

  if(id_linknx == '') then
    configured = false
  else
    configured = true
  end

  
  if(tostring(configured) == 'true') then
    self:get_ip_hc2()  
    

  else
    self:updateProperty('ui.debug.caption',"Paramètres Manquant")
  end
  --self:init_temp_piece()
end


function VoletsLinknx:get_ip_hc2()
    local url = 'http://127.0.0.1:11111/api/settings/network'
    self.headers = {
            }
     self.http:request(url, {
        options = {
            method = 'GET',
            headers = self.headers
        },
        success = function(response) 
           if (response.status == 200 and response.data) then
              local result_json = json.decode(response.data)
                if result_json.ip then
                --    self:updateProperty('ui.debug.caption', 'response mode= ' .. tostring(result_json.ip))
                    ip_hc2 = tostring(result_json.ip)
                    
           
              end
            end
        end,
        error = function(err) print(err) end
    })
end

function VoletsLinknx:set_val_knx(valeur)
	local ip_nodejs = self.properties.ip_nodejs
	local port_nodejs = self.properties.port_nodejs
	local id_linknx = self.properties.id_linknx
	local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/send_cmd?demande=linknx&id=' .. id_linknx .. '&value=' .. valeur

	self:httpRequest(url)
	self:updateProperty('ui.icone.source','http://' .. ip_hc2 .. '/plugins/com.fibaro.developer.angelz.VoletsLinknx/img/'  .. valeur .. '.png')
    --Update Slider
	self:update_slide(valeur)
	--self:updateProperty('ui.slide_volet.value',valeur)
end

--! Prepares HTTPClient object to do http request on freebox
--@param url The url
function VoletsLinknx:httpRequest(url)
	--self:updateProperty('ui.debug.caption',url)
	self.headers = {
            }
	 self.http:request(url, {
        options = {
            method = 'GET',
            headers = self.headers
        },
        success = function(data) print(data.status) end,
        error = function(err) print(err) end
    })
end


--! [public] Restart action
function VoletsLinknx:restartPlugin()
  plugin.restart()
end


function VoletsLinknx:receive_data(id,value)
    value = tostring(value)
    id = tostring(id)
    local id_linknx = self.properties.id_linknx
    if (id_linknx == id) then
        self:update_slide(value)
        self:set_val_knx(value)
        -- self:updateProperty('ui.slide_volet.value',value)
      --  self:updateProperty('ui.debug.caption',value)
    end
end

function VoletsLinknx:close()
    self:set_val_knx(100)
end

function VoletsLinknx:update_slide(valeur)
    
    self:updateProperty('ui.slide_volet.value',tonumber(valeur))
end
