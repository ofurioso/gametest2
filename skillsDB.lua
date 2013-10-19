if DEFAULT==nil then
DEFAULT={} end

DEFAULT.BaseSys=20
DEFAULT.xpskillratio=0.15
--this is a positive number, I like ranges from 0.01-0.5 lower values mean it takes more xp to get to the next skill level
DEFAULT.initgold=0
DEFAULT.startattrib=10
DEFAULT.maxattrib=20
DEFAULT.startskill=0
DEFAULT.maxskill=5
DEFAULT.damagebonuspercent=150
DEFAULT.damagebonusratio=1.5
DEFAULT.charname="blank"
DEFAULT.entitystruct= {"name","health","attribute","skill","bonus","gold"}
DEFAULT.entity={}
DEFAULT.entity.name="blank"
DEFAULT.entity.health="100"
DEFAULT.entity.attribute={["str"]=startattrib,["dex"]=startattrib,["con"]=startattrib,["int"]=startattrib,["wis"]=startattrib,["cha"]=startattrib}
DEFAULT.entity.equip={["head"]=nil,["chest"]=nil,["rightarm"]=nil,["leftarm"]=nil,["legs"]=nil,["feet"]=nil}
DEFAULT.attribute={"str","dex","con","int","wis","cha"}
DEFAULT.skill={"melee","edged","sword","broadsword","ranged","ballistic","bow","longbow","defend"}
DEFAULT.handtohandskills={"karate","kungfu","judo","aikido","boxing","kickboxing","grapling"}
DEFAULT.equip={["head"]=nil,["chest"]=nil,["rightarm"]=nil,["leftarm"]=nil,["legs"]=nil,["feet"]=nil}
DEFAULT.startinventory={}

--if gametools==nil then
--gametools=require "gametools3" end
if itemtools==nil then
itemtools=require "itemDB" end
if combatmodule==nil then
combatmodule=require "combatmodule" end

function calcsuccess(score,difficulty)
   --returns the success of a check vs a difficulty as a percent value
   return math.ceil(100*(score/difficulty))
end

function convertxptoskill(xp)
   --IMPORTANT this effects everything in the game. this equation determines how much xp in a given skill you need to receive a bonus
   local n=1
   local rawskill=math.log((xp*GAMESYS.xpskillratio)+n)
   local sp=math.floor(rawskill)
   if sp>GAMESYS.maxskill then sp=GAMESYS.maxskill end
   if sp<0 then sp=0 end
   return sp
end

function convertskilltoxp(sp)
   --IMPORTANT this function must be the opposite function from the above. solve for X
   local n=1
   if sp>GAMESYS.maxskill then sp=GAMESYS.maxskill end
   if sp<0 then sp=0 end
   local rawxp=(1/GAMESYS.xpskillratio)*((2.718281828459^sp)-n)
   xp=math.floor(rawxp)
   return xp
end

function awardxp(charid,skilltree)
   for n,skill in pairs(skilltree) do
      --use the set functions instead of the below
      increasecharskill(charid,skill)
   end
end

function useskill(charid,skilltree,diff)
   local result,relevantskill,roll,skillxp
   local skillpoints=0
   local item={}
   if type(skilltree)~="table" then
      relevantskill=skilltree
      skilltree={relevantskill}
   end
   for i,skill in pairs(skilltree) do
      --use the set functions instead of the below
      skillxp=getcharskill(charid,skill)

      if skillxp~=nil then
         relevantskill=convertxptoskill(skillxp)
         skillpoints=skillpoints+relevantskill
      else
         setcharskill(charid,skill,GAMESYS.startskill)
      end
   end
   result=rollD(GAMESYS.BaseSys)+skillpoints
   if diff~=nil then
      result=result-diff
      if result>0 then
         result = true
      else
         result = false
      end
   end
   awardxp(charid,skilltree)
   return result
end


--*********** Just for testing conversions

function testskillconv(xpinput,spinput)
   --feed me tables
   prt("xpskillratio=%s, 1/xpskillratio=%s",GAMESYS.xpskillratio,1/GAMESYS.xpskillratio)
   local xp,sp
   prt("XP to skill points")
   for i,xp in pairs(xpinput) do
      sp=convertxptoskill(xp)
      prt("%sxp is %s skill points",xp,sp)
   end
   prt("\nskill points to XP")
   for i,sp in pairs(spinput) do
      xp=convertskilltoxp(sp)
      prt("%s skill points is %sxp",sp,xp)
   end
end