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
local globalConfigured

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
  local id_linknx_val = self.properties.id_linknx_val
  local id_linknx_stop = self.properties.id_linknx_stop

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

  if(id_linknx_val == '') then
    configured = false
  else
    configured = true
  end

  if(id_linknx_stop == '') then
    configured = false
  else
    configured = true
  end

  
  if(tostring(configured) == 'true') then
    self:updateProperty('configured',true)
    globalConfigured = true;
    self:updateProperty('ui.debug.caption', '')
    self:get_ip_hc2()  
  else
    self:updateProperty('configured',false)
    self:updateProperty('ui.debug.caption', 'Paramètres de configuration Manquant')
    globalConfigured = false
   -- self.test_prop(id)
  end
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
                    
                 self:init_state()
              end
            end
        end,
        error = function(err) print(err) end
    })
end

function VoletsLinknx:set_val_knx(valeur)
  if (globalConfigured == true) then
  	local ip_nodejs = self.properties.ip_nodejs
  	local port_nodejs = self.properties.port_nodejs
  	local id_linknx_val = self.properties.id_linknx_val
    local id_linknx_stop = self.properties.id_linknx_stop
  	local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/send_cmd?demande=linknx&id=' .. id_linknx_val .. '&value=' .. valeur

  	self:httpRequest(url)
  	self:updateProperty('ui.icone.source','http://' .. ip_hc2 .. '/plugins/com.fibaro.developer.angelz.VoletsLinknx/img/'  .. valeur .. '.png')
      --Update Slider
  	self:update_slide(valeur)
    self:update_slide_tuile(valeur)
  
	end
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
  if (globalConfigured == true) then
    value = tostring(value)
    id = tostring(id)
    local id_linknx_val = self.properties.id_linknx_val
    if (id_linknx_val == id) then
        self:update_slide(value)
        self:set_val_knx(value)
        self:update_slide_tuile(value)

        -- self:updateProperty('ui.slide_volet.value',value)
      --  self:updateProperty('ui.debug.caption',value)
    end
  end
end



function VoletsLinknx:update_slide(valeur)
    
    self:updateProperty('ui.slide_volet.value',tonumber(valeur))
end




function VoletsLinknx:setAjar()
  -- Store
end

function VoletsLinknx:close()
  self:set_val_knx(0)
  --self:update_slide_tuile(0)
end

function VoletsLinknx:open()
  self:set_val_knx(100)
 -- self:update_slide_tuile(100)
end

function VoletsLinknx:setValue(arg)
 -- self:updateProperty('ui.debug.caption',tostring(arg))
 local val
 val = 100 - tonumber(arg)
 self:set_val_knx(val)
end

function VoletsLinknx:update_slide_tuile(arg)
  local valeur_inverse
  valeur_inverse = 100 - tonumber(arg)
  self:updateProperty('value',valeur_inverse)
end

function VoletsLinknx:stop()
  if (globalConfigured == true) then
    local ip_nodejs = self.properties.ip_nodejs
    local port_nodejs = self.properties.port_nodejs
    local id_linknx_val = self.properties.id_linknx_val
    local id_linknx_stop = self.properties.id_linknx_stop

    local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/send_cmd?demande=linknx&id=' .. id_linknx_stop .. '&value=off'

    self:httpRequest(url)
    self:init_state()
  end
end








function VoletsLinknx:init_state()
  if (globalConfigured == true) then
    local ip_nodejs = self.properties.ip_nodejs
    local port_nodejs = self.properties.port_nodejs
    local id_linknx_val = self.properties.id_linknx_val
    local id_linknx_stop = self.properties.id_linknx_stop
    local url = 'http://' .. ip_nodejs .. ':' .. port_nodejs .. '/etat_linknx_1_obj?id_linknx=' .. id_linknx_val 
   -- self:updateProperty('ui.debug.caption',tostring(url))
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
              --  self:updateProperty('ui.debug.caption',tostring(response.data))
                if result_json.objects then
                  if result_json.objects[1] then
                        local objet = result_json.objects[1]
                        local objet_json = objet
                        local id  = objet_json.id
                        local value  = objet_json.value
                        if (tostring(id_linknx_val) == tostring(id)) then
                          self:update_slide(value)
                          self:updateProperty('ui.icone.source','http://' .. ip_hc2 .. '/plugins/com.fibaro.developer.angelz.VoletsLinknx/img/'  .. tostring(value) .. '.png')
                          self:update_slide_tuile(value)
                        end
                  end
                end
              end
          end,
          error = function(err) self:updateProperty('ui.debug.caption', 'Err : ' .. err) end
      })
  end
end


