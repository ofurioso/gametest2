--This section is just for the game mechanics for fighting in the game. To be adjusted to be complicated or simple as you like so long as they do the right stuff and return the correct values.


if gametools==nil then
gametools=require "gametools3" end
if itemtools==nil then
itemtools=require "itemDB" end

function getinitiative(charid)
   local health
   local dex,con
   health=getcharhealth(charid)
   str=getcharattribute(charid,"str")
   dex=getcharattribute(charid,"dex")
   con=getcharattribute(charid,"con")
   return (health/(str*con))*rollD(dex)
end

function melee(aggressorid,aggfocus,targetid,targfocus)
   local hitscore,damagedealt
   local agg={}
   local target={}

   agg=getchartable(aggressorid)
   target=getchartable(targetid)
   agg["id"]=aggressorid
   target["id"]=targetid
   agg.dodge=0
   target.dodge=0

   function dofight(hitter,hitterfocus,hittee,hitteefocus)

      hitter.hitscore=useskill(hitter.id,hitter.skilltree)
      prt("%s attacks with %s",hitter.name,hitter.hitscore)
      hittee.defscore=useskill(hittee.id,"defend")+rollD(hittee.dodge)
      prt("%s deflects/dodges with %s",hittee.name,hittee.defscore)
      success=calcsuccess(hitter.hitscore,hittee.defscore)
      prt("%s percent success!",success)
      if success < 10 then
         --catastrophic fail
         feedback=hitter.name.." badly misses"
         damagedealt=0
         prt("Damage = %s. %s",damagedealt,feedback)
      else if success<100 then
            -- just fail
            feedback=hitter.name.." misses"
            damagedealt=0
            prt("Damage = %s. %s",damagedealt,feedback)
         else
            feedback=hitter.name.." hits!"
            damagedealt=calcdamage(hitter,hittee)
            if success > DEFAULT.damagebonuspercent then
               --damage bonus
               feedback=hitter.name.." critically hits!"
               damagedealt=math.ceil(damagedealt*GAMESYS.damagebonusratio)
            end
            feedback=feedback..string.format("%s suffers %s damage",hittee.name,damagedealt)

            prt("Damage = %s. %s",damagedealt,feedback)
         end
      end
      hittee.health=hittee.health-damagedealt
      if hittee.health<0 then hittee.health=0
         killchar(hittee.id,hitter.id)
      end       setcharhealth(hittee.id,hittee.health)
      return damagedealt
      --prt("",feedback)
   end --end dofight

   aggitembonus=getitembonus(agg.equip)
   aggdefbonus=getbonusdef(agg.equip)
   targetitembonus=getitembonus(target.equip)
   targetdefbonus=getbonusdef(target.equip)

   agg.skilltree=getitemsskilltree(agg.equip)
   target.skilltree=getitemsskilltree(target.equip)

   for stat,bonus in pairs(aggitembonus) do
      if bonus~=nil then
         agg.attribute[stat]=agg.attribute[stat]+bonus
      end
      if (aggdefbonus[stat]~=nil) then
         agg.dodge=agg.dodge+(aggdefbonus[stat]*agg.attribute[stat])
      end
   end
   for stat,bonus in pairs(targetitembonus) do
      if bonus~=nil then
         target.attribute[stat]=target.attribute[stat]+bonus

      end
      if (targetdefbonus[stat]~=nil) then
         target.dodge=target.dodge+(targetdefbonus[stat]*target.attribute[stat])
      end
   end
   agg.initiative=getinitiative(aggressorid)
   target.initiative=getinitiative(targetid)
   prt("%s rolls %s for intitiative",agg.name,agg.initiative)
   prt("%s rolls %s for intitiative",target.name,target.initiative)
   if agg.initiative>=target.initiative then
      --aggressor attacks first
      prt("%s attacks first",agg.name)
      damage=dofight(agg,aggfocus,target,targfocus)
      if target.health>0 then
         damage=dofight(target,targfocus,agg,aggfocus)
      end
   else
      prt("%s attacks first",target.name)
      damage=dofight(target,targfocus,agg,aggfocus)
      damage=dofight(agg,aggfocus,target,targfocus)
   end
end


function calcdamage(agg,target)
   local basedmg=0
   local bonusdmg=0
   local damage,potentialdmg,statdmg
   local basedef=getbasedef(target.equip)
   if agg.equip.rightarm==false and agg.equip.leftarm==false then
      --brawling
      prt("Using bare hands")
      basedmg=agg.attribute.str/2
      bonusdmg=rollD(math.floor(agg.attribute.str/2))
   else
      --using a weapon
      basedmg=getbasedmg(agg.equip)
   end
   prt("basedmg = %s",basedmg)
   --add bonusdmg
   local bonusdmgtable=getbonusdmg(agg.equip)
   for stat,dmg in pairs(bonusdmgtable) do
      if dmg~=0 and dmg~=nil then
         if agg.attribute[stat]~=nil then
            potentialdmg=(agg.attribute[stat]*dmg)
         else if agg.skill[stat]~=nil then
               potentialdmg=(agg.skill[stat]*dmg)
            else potentialdmg=0
            end
         end

         if agg.attribute[stat]~=nil or agg.skill[stat]~=nil then         statdmg=rollD(potentialdmg)
            bonusdmg=bonusdmg+statdmg
         end
      end
   end
   prt("%s damage absorbed by %s's armor",basedef,target.name)
   --mitigate with base defense
   damage=math.floor(basedmg+bonusdmg-basedef)

   if damage<0 then damage=0 end

   return damage
end