/*-----------------------------------------------------------------------------
  Auth: Tobba
  Name: Skybox Module
  Desc: Skybox utils.
-----------------------------------------------------------------------------*/

// Making our globals into locals for some speed enhancement
local SetGlobalString = SetGlobalString
local GetGlobalString = GetGlobalString
local type = type
local Material = Material
local pairs = pairs
local table = table
local Vector = Vector

MODULE.Name = "skybox" -- The reference name
MODULE.Title = "Skybox module" -- The display name
MODULE.Author = "Tobba" -- The author
MODULE.Contact = "" -- The author's contact
MODULE.Purpose = "Skybox utils." -- The purpose
MODULE.SkyboxName = ""


MODULE:Hook("EntityKeyValue", "GetSkyboxName", function(ent,key,val)
	if ent:GetClass() == "worldspawn" and key == "skyname" then
		SetGlobalString("SkyboxName", val)
	end
end)

function MODULE:GetSkyboxName()
	return GetGlobalString("SkyboxName")
end

if !CLIENT then return end

local CurrentSkyboxR = 255
local CurrentSkyboxG = 255
local CurrentSkyboxB = 255
local DefaultMats
local SkyboxTex
local SkyboxTexOld = 0 -- Put this to something random
local SkyTextures = {}
local Materials
local suffix = { "up", "dn", "lf", "rt", "bk", "ft" }
local skyname

function MODULE:SetSkyColor(r,g,b)
	if type(r) == "table" then
		CurrentSkyboxR = r.r
		CurrentSkyboxG = r.g
		CurrentSkyboxB = r.b
	else
		CurrentSkyboxR = r
		CurrentSkyboxG = g
		CurrentSkyboxB = b
	end
end

function MODULE:SetSkyTexture(tex)
	SkyboxTex = tex
end

MODULE:Hook( "Think", "ApplySkybox", function()
	skyname = GetGlobalString("SkyboxName")
	if skyname == "" then return end
	if !Materials then
		Materials = { Material("skybox/" .. skyname .. "up"), Material("skybox/" .. skyname .. "dn"), Material("skybox/" .. skyname .. "lf"), Material("skybox/" .. skyname .. "rt"), Material("skybox/" .. skyname .. "bk"), Material("skybox/" .. skyname .. "ft") }
	end

	if !DefaultMats then
		DefaultMats = {}
		for k, v in pairs(Materials) do
			DefaultMats[k] = v:GetMaterialTexture("$basetexture")
		end
	end

	if SkyboxTex != SkyboxTexOld then
		if SkyboxTex then
			for k,v in pairs(suffix) do
				SkyTextures[k] = Material(/*"skybox/" .. */SkyboxTex .. v):GetMaterialTexture("$basetexture")
			end
		else
			SkyTextures = table.Copy(DefaultMats) -- Just in case
		end
		SkyboxTexOld = SkyboxTex
	end
	if SkyboxTex then
		for k,v in pairs(Materials) do
			v:SetMaterialTexture("$basetexture",SkyTextures[k])
			if CurrentSkyboxR != 255 or CurrentSkyboxG != 255 or CurrentSkyboxB != 255 then
				v:SetMaterialVector("$color", Vector(CurrentSkyboxR/255, CurrentSkyboxG/255, CurrentSkyboxB/255))
			end
		end
	else
		for k,v in pairs(Materials) do
			if CurrentSkyboxR != 255 or CurrentSkyboxG != 255 or CurrentSkyboxB != 255 then
				v:SetMaterialVector("$color", Vector(CurrentSkyboxR/255, CurrentSkyboxG/255, CurrentSkyboxB/255))
			end
		end
	end
end )


