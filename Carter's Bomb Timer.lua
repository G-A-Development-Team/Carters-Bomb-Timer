function using(pkgn) file.Write( "\\using/json.lua", http.Get( "https://raw.githubusercontent.com/G-A-Development-Team/libs/main/json.lua" ) ) LoadScript("\\using/json.lua") local pkg = json.decode(http.Get("https://raw.githubusercontent.com/G-A-Development-Team/Using/main/using.json"))["pkgs"][ pkgn ] if pkg ~= nil then file.Write( "\\using/" .. pkgn .. ".lua", http.Get( pkg ) ) LoadScript("\\using/" .. pkgn .. ".lua") else print("[using] package doesn't exist. {" .. pkgn .. "}") end end

-------------------------------------------------
--------   Carter's Bomb Timer   ----------------
--------      Created By:         ---------------
--------       CarterPoe          ---------------
--------     Date: 7/24/2022       --------------
-------------------------------------------------
--------  Tested By:             ----------------
--------  Agentsix1              ----------------
-------------------------------------------------
--
-- This is a product of the G&A Development Team
--
------------------------------
---  Credit To: Cheeseot   ---
---       Bomb Stuff       ---
------------------------------
--G&A Scripts--
--https://aimware.net/forum/thread/168242 Shared Music Kit Changer
--https://aimware.net/forum/thread/168291 Health Bars Plus v0.2
--https://aimware.net/forum/thread/148544 Health Bars Plus v0.1
--https://aimware.net/forum/thread/168280 [Library] Draggable/Resizable Windows

local Tab = gui.Tab(gui.Reference("Visuals"), "aa_t", "Carter's Bomb Timer");
local bt_x = gui.Editbox(Tab, "bt_x", "X")
local bt_y = gui.Editbox(Tab, "bt_y", "Y")

using "Move-Resize"
using "WinFormLib"
using "WinFormColors"
using "WinFormToolbox"
using "WinForm"
using "BombAPI"

if tonumber(bt_x:GetValue()) == nil then bt_x:SetValue("30") end
if tonumber(bt_y:GetValue()) == nil then bt_y:SetValue("350") end
local function getX() if tonumber(bt_x:GetValue()) == nil then return 30 else return tonumber(bt_x:GetValue()) end end
local function getY() if tonumber(bt_y:GetValue()) == nil then return 350 else return tonumber(bt_y:GetValue()) end end

local FrmTimer = {
	Name = "FrmTimer",
	Interface = "Form",
	Size = size(125, 67),
	Location = point(getX(), getY()),
	MinimumSize = size(100, 80),
	MaximumSize = size(150, 80),
	DragBounds = 80,
	BorderStyle = "None", --None
	WinStyle = 10,
	Visible = true,
	BackColor = color(20,20,20,210),
	TitleBarColor = SystemColors.White,
	ForeColor = SystemColors.Black,
	BorderShadow = true,
	BorderShadowColor = color(40, 40, 40, 255),
	BorderShadowRadius = 10,
}

FrmTimer.Initialize = function()
	local pb_bomb = Toolbox.PictureBox()
	pb_bomb.Properties.Name = "pb_bomb"
	pb_bomb.Properties.Size = size(60,50)
	pb_bomb.Properties.Icon = "https://raw.githubusercontent.com/G-A-Development-Team/AA-Bomb-Timer/main/bomb3.png"
	pb_bomb.Properties.Location = point(-8, 0)
	
	local prog_bar = Toolbox.ProgressBar()
	prog_bar.Properties.Name = "prog_bomb"
	prog_bar.Properties.BorderColor = SystemColors.Transparent
	prog_bar.Properties.BackColor = SystemColors.Transparent
	prog_bar.Properties.Size = size(121 ,10)
	prog_bar.Properties.Value = 0
	prog_bar.Properties.Maximum = 40
	prog_bar.Properties.Location = point(2, 55)
	
	local prog_bar_defuse = Toolbox.ProgressBar()
	prog_bar_defuse.Properties.Name = "prog_bomb_defuse"
	prog_bar_defuse.Properties.BackColor = SystemColors.Transparent
	prog_bar_defuse.Properties.BorderColor = SystemColors.Transparent
	prog_bar_defuse.Properties.ValueColor = SystemColors.Blue
	prog_bar_defuse.Properties.Size = size(121 ,4)
	prog_bar_defuse.Properties.Value = 0
	prog_bar_defuse.Properties.Maximum = 1
	prog_bar_defuse.Properties.Location = point(2, 61)
	
	local lb_secs = Toolbox.Label()
	lb_secs.Properties.Name = "lb_bomb"
	lb_secs.Properties.Text = "0.0s"
	lb_secs.Properties.ForeColor = SystemColors.White
	lb_secs.Properties.Font.Name = "Bahnschrift"
	lb_secs.Properties.Font.Size = 17
	lb_secs.Properties.Location = point(38, -2)
	
	local lb_dmg = Toolbox.Label()
	lb_dmg.Properties.Name = "lb_dmg"
	lb_dmg.Properties.Text = "0 damage"
	lb_dmg.Properties.ForeColor = SystemColors.Grey
	lb_dmg.Properties.Font.Name = "Bahnschrift"
	lb_dmg.Properties.Font.Size = 15
	lb_dmg.Properties.Location = point(38, 15)
	
	return { pb_bomb, prog_bar, prog_bar_defuse, lb_secs, lb_dmg, }
end
FrmTimer = Application.Run(FrmTimer)

local timePlanted = 0 local defusing = false local ended = false

callbacks.Register("FireGameEvent", function(event)
	if event:GetName() == "bomb_planted" then timePlanted = globals.CurTime() ended = false end
	if event:GetName() == "bomb_begindefuse" then defusing = true ended = false end
	if event:GetName() == "bomb_abortdefuse" then defusing = false ended = false end
	if event:GetName() == "bomb_defused" then ended = true end
	if event:GetName() == "bomb_exploded" then ended = true end
	if event:GetName() == "round_officially_ended" then ended = true end
end)

callbacks.Register("Draw", function()
	if FrmTimer.Dragging then
		bt_x:SetValue(FrmTimer.Location.X)
		bt_y:SetValue(FrmTimer.Location.Y)
	else FrmTimer.Location = point(tonumber(bt_x:GetValue()), tonumber(bt_y:GetValue())) end

	FrmTimer.Visible = not ended
	
	if entities.FindByClass("CPlantedC4")[1] ~= nil then
		local Bomb = entities.FindByClass("CPlantedC4")[1];	
		local BombMath = ((globals.CurTime() - Bomb:GetProp("m_flC4Blow")) * (0 - 1)) / ((Bomb:GetProp("m_flC4Blow") - Bomb:GetProp("m_flTimerLength")) - Bomb:GetProp("m_flC4Blow")) + 1;
		local bombtimer = math.floor((timePlanted - globals.CurTime() + Bomb:GetProp("m_flTimerLength")) * 10) / 10
		
		FrmTimer.Controls[FrmTimer.Controls.Find("prog_bomb")].Properties.Value = bombtimer
		
		if bombtimer <= 0 then FrmTimer.Visible = false end
		
		if bombtimer <= 5 then FrmTimer.Controls[FrmTimer.Controls.Find("prog_bomb")].Properties.ValueColor = SystemColors.Red
		elseif bombtimer <= 10 then FrmTimer.Controls[FrmTimer.Controls.Find("prog_bomb")].Properties.ValueColor = SystemColors.Yellow
		else FrmTimer.Controls[FrmTimer.Controls.Find("prog_bomb")].Properties.ValueColor = SystemColors.Green end
		
		bombtimer = tostring(bombtimer)
		if not string.find(bombtimer, "%.") then bombtimer = bombtimer .. ".0" end
		
		FrmTimer.Controls[FrmTimer.Controls.Find("lb_bomb")].Properties.Text = bombtimer .. "s"
		
		local hpleft = math.floor(0.5 + BombDamage(Bomb, entities.GetLocalPlayer()))
		if hpleft >= entities.GetLocalPlayer():GetHealth() then
			FrmTimer.Controls[FrmTimer.Controls.Find("lb_dmg")].Properties.ForeColor = SystemColors.Red
			FrmTimer.Controls[FrmTimer.Controls.Find("lb_dmg")].Properties.Text = "Fatal"
		else
			FrmTimer.Controls[FrmTimer.Controls.Find("lb_dmg")].Properties.ForeColor = SystemColors.Grey
			FrmTimer.Controls[FrmTimer.Controls.Find("lb_dmg")].Properties.Text = tostring(hpleft) .. " damage"
		end
		if defusing then
			BombMath = ((globals.CurTime() - Bomb:GetProp("m_flDefuseCountDown")) * (0 - 1)) / ((Bomb:GetProp("m_flDefuseCountDown") - Bomb:GetProp("m_flDefuseLength")) - Bomb:GetProp("m_flDefuseCountDown")) + 1;
			FrmTimer.Controls[FrmTimer.Controls.Find("prog_bomb_defuse")].Properties.Value = BombMath
			
			bombtimer = math.floor((timePlanted - globals.CurTime() + Bomb:GetProp("m_flTimerLength")) * 10) / 10
			local defusetime = math.floor((Bomb:GetProp("m_flDefuseCountDown") - globals.CurTime()) * 10) / 10
			
			if bombtimer >= defusetime then
				FrmTimer.Controls[FrmTimer.Controls.Find("prog_bomb_defuse")].Properties.ValueColor = SystemColors.Blue
			else FrmTimer.Controls[FrmTimer.Controls.Find("prog_bomb_defuse")].Properties.ValueColor = SystemColors.Yellow end
			
		else FrmTimer.Controls[FrmTimer.Controls.Find("prog_bomb_defuse")].Properties.Value = 0 end
	else ended = true defusing = false timePlanted = 0 FrmTimer.Visible = false end end)
