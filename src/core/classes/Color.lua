--------------------------------------------------------
-- Classes - Color
--------------------------------------------------------

--[[
    Copyright (C) 2026 cuhHub

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]

-------------------------------
-- // Main
-------------------------------

--[[
    A class representing a color. Contains R, G, B, and A components.
]]
---@class Color: NoirClass
---@field New fun(self: Color, R: number, G: number, B: number, A: number): Color
---@field R number The red component
---@field G number The green component
---@field B number The blue component
---@field A number The alpha component
Addon.Classes.Color = Noir.Libraries.Dataclasses:New("Color", {
    Noir.Libraries.Dataclasses:Field("R", "number"),
    Noir.Libraries.Dataclasses:Field("G", "number"),
    Noir.Libraries.Dataclasses:Field("B", "number"),
    Noir.Libraries.Dataclasses:Field("A", "number")
})

--[[
    Returns all of the components.
]]
---@return number, number, number, number
function Addon.Classes.Color:GetComponents()
    return self.R, self.G, self.B, self.A
end