-- perpendicular vector
function perpendicular(v)
	return Vector(-v.y,v.x,0)
end

function RandomPointInRadius(point, radius)
    local r = radius * math.sqrt(RandomFloat(0, 1))
    local theta = RandomFloat(0, 1) * 2 * math.pi
    local x = point.x + r * math.cos(theta)
    local y = point.y + r * math.sin(theta)
    return Vector(x, y, point.z)
end


function RandomPointOnCPerpeircle(point, radius)
    local r = radius 
    local theta = RandomFloat(0, 1) * 2 * math.pi
    local x = point.x + r * math.cos(theta)
    local y = point.y + r * math.sin(theta)
    return Vector(x, y, point.z)
end

function RandomPointForSummon(unit,radius)
    local r = radius * math.sqrt(RandomFloat(0, 1))
    local point=unit:GetAbsOrigin()+(radius+50)*unit:GetForwardVector()
    local theta = RandomFloat(0, 1) * 2 * math.pi
    local x = point.x + r * math.cos(theta)
    local y = point.y + r * math.sin(theta)
    return Vector(x, y, point.z)
end
function angleOf2Unit(v1, v2)
    local d1 = v1:GetAnglesAsVector().y
    local d2 = v2:GetAnglesAsVector().y
    return AngleDiff(d1, d2)
end

function angleOf2Vector(v1, v2)
    local d1 = VectorToAngles(v1).y
    local d2 = VectorToAngles(v2).y
    return AngleDiff(d1, d2)
end

function GenPointsForSummon(unit,distance,gapWidth,count)
    local pCenter=unit:GetAbsOrigin()+distance*unit:GetForwardVector()
    if count<=0 then
        return {}
    end
    local dir=perpendicular(unit:GetForwardVector()):Normalized()
    if count==1 then
        return {pCenter}
    end
    local width=gapWidth*(count-1)
    local p1=pCenter+dir*width/2
    local res={}
    for i = 0, count-1 do
        table.insert(res,p1-gapWidth*dir*i)
    end
    return res
end

function Shuffle(t)
    if t==nil then
        return nil
    end
    local s = {}
    for i = 1, #t do
        s[i] = t[i]
    end
    for i = #t, 2, -1 do
        local j = math.random(i)
        s[i], s[j] = s[j], s[i]
    end
    return s
end
function Normalized2D(vec)
    local newVec = Vector(vec.x, vec.y, 0)
    return newVec:Normalized()
end

function distanceFromPointToLine(pos, p1, p2)
    local a = math.abs((p2.x - p1.x) * (p1.y - pos.y) - (p1.x - pos.x) * (p2.y - p1.y))
    local b = math.sqrt(math.pow(p2.x - p1.x, 2) + math.pow(p2.y - p1.y, 2))
    return a / b
end
function Distance(unitA, unitB)
    if not unitA or not unitB then
        return 1000000
    end
    return (unitA:GetAbsOrigin() - unitB:GetAbsOrigin()):Length2D()
end
