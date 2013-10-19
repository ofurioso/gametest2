if DEFAULT==nil then
DEFAULT={} end

DEFAULT.BaseSys=100
DEFAULT.xpskillratio=0.15

--if gametools==nil then
--gametools=require "gametools3" end
if chartools==nil then
chartools=require "charDB" end
if skilltools==nil then
skilltools=require "skillsDB" end
if itemtools==nil then
itemtools=require "itemDB" end

--The main Game Loop

table.insert(charDB,getblankchar())
heroid=#charDB
displaychar(heroid)
setcharname(heroid,"frank")
setcharattribute(heroid,"str",12)
--setcharskillxp(heroid,"melee",150)
equipitem(heroid,1,"rightarm")

--testskillconv(examplexp,examplesp)
table.insert(charDB,getblankchar())
setcharname(heroid+1,"buster")

setcharattribute(heroid+1,"dex",13)

equipitem(heroid+1,4,"head")

for count,char in pairs(charDB) do
   prt("\n\nDisplaying charDB[ %s ]",count)
   displaychar(count)
end

--prt("\nSuccess is %s",calcsuccess(99,100)) --debug

repeat
   displaychar(heroid)
   prompt="Please enter a command: "
   commands={"f","d","r","q"}
   action=getcommand(prompt,commands)
   if action=="f" then melee(heroid,"f",(heroid+1),"d")
   else
      if action=="d" then defend(heroid,heroid+1)
      else
         if action=="r" then runaway(heroid,heroid+1)
         else if action=="q" then endgame=true
            end
         end
      end
   end
until endgame==true
prt("the end")