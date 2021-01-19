local hitbox = script.Parent:FindFirstChild("Hitbox") or script.Parent:WaitForChild("Hitbox")

repeat wait() until #hitbox:GetChildren() == 6
	
for _,p in pairs(hitbox:GetChildren()) do
	p.Touched:Connect(function(hit)
		if not hit:FindFirstChild("KillPartObject") then return end
		local hum = script.Parent:FindFirstChild("Humanoid")
		if not hum then return end
		if hum.Health == 0 then return end
		hum.Health = 0
	end)
end
