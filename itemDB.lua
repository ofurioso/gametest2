--notes: items are a little tricky because we want not only perfect items--the models of items, 'archetypes' I'm calling them, but also instances of those objects. That way we can have multiple copies of items and things can get broken or enchanted or cursed or whatever and we don't need to worry about mucking up every copy of that item in the game.

if DEFAULT==nil then
DEFAULT={} end

DEFAULT.BaseSys=100
DEFAULT.equip={["head"]=false,["chest"]=false,["rightarm"]=false,["leftarm"]=false,["legs"]=false,["feet"]=false}
DEFAULT.entity={}
DEFAULT.entity.attribute={}
DEFAULT.entity.attribute={["str"]=0,["dex"]=0,["con"]=0,["int"]=0,["wis"]=0,["cha"]=0}
DEFAULT.item={}
DEFAULT.item.name="item"
DEFAULT.item.hp=1
DEFAULT.item.encumberance=0
DEFAULT.item.basedmg=0
DEFAULT.item.basedef=0
DEFAULT.item.bonusdmg={} --per skill/attrib
DEFAULT.item.bonusdef={} --per skill/attrib
DEFAULT.item.skilltree={}
DEFAULT.item.equiptree={["head"]=false,["chest"]=false,["rightarm"]=false,["leftarm"]=false,["legs"]=false,["feet"]=false}
DEFAULT.item.bonustree={}

if gametools==nil then
gametools=require "gametools3" end

if archDB==nil then
archDB={} end --the archetype database
if itemDB==nil then
itemDB={} end --item instances of archetypes

itemproperties={"name","hp","skilltree","basedmg","bonusdmg","basedef","bonusdef","bonusdmg","bonustree","equiptree"}

function displayitem(itemid)
   local itemname=getitemname(itemid)
   prt(itemname)

end

function getitemname(itemid)
   return getiteminfo(itemid,"name")
end

function getiteminfo(itemid,stat)
   --specifically for one stat one item
   item=itemDB[itemid]
   if item~=nil then
      return item[stat]
   else
      prt("%s is not a valid itemid",itemid)
   end
end

function setiteminfo(itemid,stat,newvalue)
   --specifically for one stat one item
   item=itemDB[itemid]
   if item~=nil then
      itemDB[itemid][stat]=newvalue
   else
      prt("%s is not a valid itemid",itemid)
   end
end

function getbasedmg(itemidlist)
   --takes a table of items and sums their basedmg. Also works for single items. Returns a number. Handy for assessing all the equipped items of a given entity.
   if type(itemidlist)~="table" then
   itemidlist={itemidlist} end
   local itemlist={}
   itemlist=makeitemtable(itemidlist)
   totalbonus=tablesum("basedmg", itemlist)
   return totalbonus
end

function getbasedef(itemidlist)
   --takes a table of items and sums their bonusdef. Also works for single items. Returns a table of bonuses indexed by stat. Handy for assessing all the equipped items of a given entity.
   if type(itemidlist)~="table" then
   itemidlist={itemidlist} end
   local itemlist={}
   itemlist=makeitemtable(itemidlist)
   totalbonus=tablesum("basedef", itemlist)
   return totalbonus
end

function getitembonus(itemidlist)
   --takes a table of items and sums their bonuses. Also works for single items. Returns a table of bonuses indexed by stat. Handy for assessing all the equipped items of a given entity.
   if type(itemidlist)~="table" then
   items={itemidlist} end
   local totalbonuses={}
   local itemlist={}
   local totalbonuses={}
   itemlist=makeitemtable(itemidlist)
   totalbonuses=tablesumtable(GAMESYS.entity.attribute,"bonustree",itemlist)
   return totalbonuses
end

function getitemsskilltree(itemidlist)
   --takes a table of items and returns a compiled skilltree. Also works for single items. Returns a table of skillnames. Handy for assessing all the equipped items of a given entity.
   if type(itemidlist)~="table" then
   items={itemidlist} end
   local count,num
   local allskills={}
   local itemlist={}
   local item={}
   itemlist=makeitemtable(itemidlist)
   for count,item in pairs(itemlist) do
      for num,skill in pairs(item.skilltree) do
         table.insert(allskills,skill)
      end
   end
   return allskills
end

function getbonusdef(itemidlist)
   --takes a table of items and sums their bonusdef. Also works for single items. Returns a table of bonuses indexed by stat. Handy for assessing all the equipped items of a given entity.
   if type(itemidlist)~="table" then
   itemidlist={itemidlist} end
   local itemlist={}
   local totalbonuses={}
   itemlist=makeitemtable(itemidlist)
   totalbonuses=tablesumtable(GAMESYS.entity.attribute,"bonusdef",itemlist)

   return totalbonuses
end

function getbonusdmg(itemidlist)
   --takes a table of itemids and sums their bonuses. Also works for single items. Returns a table of bonuses indexed by stat. Handy for assessing all the equipped items of a given entity.
   if type(itemidlist)~="table" then
   itemidlist={itemidlist} end
   local itemlist={}
   local totalbonuses={}
   itemlist=makeitemtable(itemidlist)
   totalbonuses=tablesumtable(GAMESYS.entity.attribute,"bonusdmg",itemlist)

   return totalbonuses
end

function makeitemtable(idlist)
   --converts a table of item ids into a table of items
   local items={}
   local count,itemid
   for count,itemid in pairs(idlist) do
      table.insert(items,itemDB[itemid])
   end
   return items
end

--************************Creation Code

function getnewarchetype()
   local template=GAMESYS.item
   local archetype={}
   for stat,default in pairs(template) do
      if type(default)=="table" then
         archetype[stat]=instancize(default)
      else
         archetype[stat]=default
      end
   end
   return archetype
end

function makeiteminstance(archid)
   table.insert(itemDB,instancize(archDB[archid]))
   newitemid=#itemDB
   itemDB[newitemid].archref=archid
   return newitemid
end

--*************************Testing Code

function testitem()

   swordtemplate=getnewarchetype()
   swordtemplate.equiptree={["rightarm"]=true,["leftarm"]=true}
   swordtemplate.skilltree={"melee","edged","sword","broadsword"}
   swordtemplate.name="steel sword"
   swordtemplate.hp=1000
   swordtemplate.basedmg=7
   swordtemplate.bonusdmg={["str"]=1.25}
   swordtemplate.basedef=0
   swordtemplate.bonusdef={["dex"]=.25}
   table.insert(archDB,instancize(swordtemplate))
   swordid=#archDB
   firstitemid=makeiteminstance(swordid)
   nextitemid=makeiteminstance(swordid)
   setiteminfo(firstitemid,"name","rusty iron sword")
   setiteminfo(firstitemid,"basedmg",18)

   prt("item :%s\n",firstitemid)
   displayitem(firstitemid)
   prt("\nitem :%s\n",nextitemid)
   displayitem(nextitemid)
   thirditemid=makeiteminstance(swordid)
   prt("\nitem :%s\n",thirditemid)
   displayitem(thirditemid)

   for key,value in pairs(GAMESYS.entity.attribute) do
      prt("%s : %s",key,value)
   end

   itemidlist={firstitemid,nextitemid,thirditemid}
   itemlist=makeitemtable(itemidlist)
   itembasedmg=getbasedmg(itemidlist)
   prt("total basedmg = %s",itembasedmg)
   itembonusdmg=getbonusdmg(itemidlist)

   --itembonusdmg=tablesum(GAMESYS.entity.attribute,"bonusdmg",itemlist)
   prt("str bonus = %s",itembonusdmg.str)

   helmtemplate=getnewarchetype()
   helmtemplate.equiptree["head"]=true
   helmtemplate.skilltree={}
   helmtemplate.name="bronze helm"
   helmtemplate.hp=1000
   helmtemplate.basedmg=0
   helmtemplate.bonusdmg={}
   helmtemplate.basedef=10
   helmtemplate.bonusdef.dex=0.5
   table.insert(archDB,instancize(helmtemplate))
   helmid=#archDB
   firstarmorid=makeiteminstance(helmid)

   prt("item :%s\n",firstarmorid)
   displayitem(firstarmorid)
end

testitem()
