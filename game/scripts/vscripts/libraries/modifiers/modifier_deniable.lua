modifier_deniable = class({})

function modifier_deniable:OnCreated(event)
end

function modifier_deniable:CheckState() 
    return {
             [MODIFIER_STATE_SPECIALLY_DENIABLE] =true
         }
end

function modifier_deniable:IsHidden()
    return true
end

function modifier_deniable:IsPurgable()
    return false
end