modifier_casting = class({})

function modifier_casting:OnCreated(event)
end

function modifier_casting:CheckState() 
    return {
         }
end

function modifier_casting:IsHidden()
    return true
end

function modifier_casting:IsPurgable()
    return false
end