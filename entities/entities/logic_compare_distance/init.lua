
ENT.Base 			= "base_entity"
ENT.Type 			= "point"

/*
Key Values:
Compare <number> - Value to compare against
Val[ID] <number> - A value. The ID you use will correspond with SetVal and OnVal. The ID can be a letter, number, or even a word (remove the []).

Inputs:
SetVal[ID] <number> - Sets the Value with ID (remove the []).
SetComparison <number> - Sets the comparison value.

Outputs:
OnVal[ID] - Fired when the corresponding Value ID becomes closest to the Comparison value (remove the []).

OnVal1 : ("<", ">", "=", "<=", ">=") : ("compare","val[id]",int)

*/

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()
	self.Vals = {}
	self.Compare = nil
	self.Closest = nil
	self.LastClosest = nil
end


/*---------------------------------------------------------
   Name: KeyValue
   Desc: Called when a keyvalue is added to us
---------------------------------------------------------*/
function ENT:KeyValue( key, value )
	key = string.lower(key)
	if key == "comparison" then
		self.Compare = value
	elseif key == "val*" then
		self.Vals[string.sub( key, 4 )] = value
	elseif key == "onval*" then
		self:StoreOutput( key, value )
	end
end


/*---------------------------------------------------------
   Name: AcceptInput
   Desc: Accepts input, return true to override/accept input
---------------------------------------------------------*/
function ENT:AcceptInput( name, activator, caller, data )
	name = string.lower(name)
	if name == "setval*" then
		if self.Vals[string.sub( name, 7 )] then
			self.Vals[string.sub( name, 7 )] = data
		end
	elseif name = "createval" then
		local rawData = string.Explode(",", data)
		if !self.Vals[rawData[1]] then
			self.Vals[rawData[1]] = rawData[2]
		end
	elseif name == "setcomparison" then
		self.Compare = data
	end
	return true
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity's think function. 
---------------------------------------------------------*/
function ENT:Think()
	local absolute = math.abs
	local c = self.Closest
	for k, v in pairs( self.Vals ) do
		if !self.Closest or absolute( self.Compare - v ) < absolute( self.Compare - self.Vals[self.Closest] ) then
			self.Closest = k
		end
	end
	if self.Closest != c then
		self:TriggerOutput("OnVal"..self.Closest, self)
	end
end



