modifier_levelup_channel_cast = class({})

function modifier_levelup_channel_cast:OnCreated(event)
    if not IsServer() then return end

    local caster=self:GetCaster()

    SimpleAddEff(self,self:GetParent(),"particles/econ/events/fall_major_2015/teleport_start_fallmjr_2015_counter.vpcf",nil)
    EmitSoundOn("Portal.Loop_Appear", caster)
end

function modifier_levelup_channel_cast:OnDestroy(event)
    if not IsServer() then return end
    local caster=self:GetCaster()
    StopSoundOn("Portal.Loop_Appear", caster)
end

function modifier_levelup_channel_cast:CheckState() 
    return {
            --  [MODIFIER_STATE_STUNNED] =true,
            --  [MODIFIER_STATE_FROZEN] =true,
            [MODIFIER_STATE_DISARMED] =true,
         }
end

function modifier_levelup_channel_cast:IsHidden()
    return false
end

function modifier_levelup_channel_cast:IsPurgable()
    return false
end