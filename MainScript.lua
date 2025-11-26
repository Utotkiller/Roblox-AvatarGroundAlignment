local function UpdateRigForPlayer(rig, userId, targetCFrame)
	--[[
		⚡ PURPOSE:
		• Load a user's avatar onto a dummy rig
		• Find how far the HumanoidRootPart is from the bottom of the feet
		• Reposition the entire rig so that the FEET sit exactly on the ground
		• Play an idle animation
	--]]

	local humanoid = rig:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Load the user's avatar appearance
	local desc = Players:GetHumanoidDescriptionFromUserId(userId)
	humanoid:ApplyDescription(desc)

	-- Allow time for body parts (legs, feet) to exist
	task.wait()

	local hrp = rig:FindFirstChild("HumanoidRootPart")
	if not hrp then return end


	---------------------------------------------------------------------
	-- 📌 STEP 1: Find the lowest point of the character’s feet
	-- Why do we do this?
	--   Because the HumanoidRootPart (HRP) is NOT at ground level.
	--   It's located in the CENTER of the character.
	--
	--   So if we place the HRP on the ground, the FEET will sink underground.
	--
	--   We calculate:
	--     • where the bottoms of the feet are
	--     • how high HRP sits above the feet
	---------------------------------------------------------------------

	local bottomY = math.huge -- start with a large number

	if humanoid.RigType == Enum.HumanoidRigType.R15 then
		-- R15 rigs have "LeftFoot" and "RightFoot"
		local leftFoot = rig:FindFirstChild("LeftFoot")
		local rightFoot = rig:FindFirstChild("RightFoot")

		if leftFoot and rightFoot then
			-- bottom of part = its position minus half of its height
			local leftBottom = leftFoot.Position.Y - (leftFoot.Size.Y / 2)
			local rightBottom = rightFoot.Position.Y - (rightFoot.Size.Y / 2)

			-- lowest foot determines TRUE ground contact
			bottomY = math.min(leftBottom, rightBottom)
		end

	else
		-- R6 uses "Left Leg" and "Right Leg" (full leg parts)
		local leftLeg = rig:FindFirstChild("Left Leg")
		local rightLeg = rig:FindFirstChild("Right Leg")

		if leftLeg and rightLeg then
			-- R6 legs: bottom = position minus leg height
			local leftBottom = leftLeg.Position.Y - leftLeg.Size.Y
			local rightBottom = rightLeg.Position.Y - rightLeg.Size.Y

			bottomY = math.min(leftBottom, rightBottom)
		end
	end


	---------------------------------------------------------------------
	-- 📌 STEP 2: Measure the vertical distance between the HRP and FEET
	---------------------------------------------------------------------

	local footToHRP = hrp.Position.Y - bottomY
	-- Example:
	--   HRP at Y = 6
	--   Feet bottom at Y = 0
	--   → footToHRP = 6 (HRP is 6 studs above ground)



	---------------------------------------------------------------------
	-- 📌 STEP 3: Move the entire rig so the FEET sit exactly on targetCFrame
	--
	-- "targetCFrame" = the desired position of the feet.
	-- We shift the HRP UP by the correct offset so feet align perfectly.
	---------------------------------------------------------------------

	rig:PivotTo(
		targetCFrame * CFrame.new(0, footToHRP, 0)
	)



	---------------------------------------------------------------------
	-- 📌 STEP 4: Play animation on the character
	---------------------------------------------------------------------

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	}

	local animation = Instance.new("Animation")
	animation.AnimationId = AnimationId

	local track = animator:LoadAnimation(animation)
	track.Looped = true
	track:Play()
end
