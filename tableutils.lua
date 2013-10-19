-- GENERAL UTILITY FUNCTIONS*****

function showtable(table)
   prt("Showing %s",table) --debug
   for key,value in pairs(table) do
      prt("%s -> %s",key,value)
   end
end

function simpleinstancize(table)
   --only instancizes the surface table if there is a subtable in table, it will wind up a reference
   local copy={}
   -- prt("instancizing") --debug
   for key,value in pairs(table) do
      copy[key]=value
      -- prt("%s ->> %s",key,value) --debug
   end
   return copy
end

function instancize(table)
   --goes one deep in instancizing so a nested table, inside table will also be instancized. not smart enough to go any deeper, sorry.
   local copy={}
   local subtable={}
   -- prt("instancizing") --debug
   for key,value in pairs(table) do
      if type(value)=="table" then
         subtable=simpleinstancize(value)
         copy[key]=subtable
      else
         copy[key]=value
      end
      -- prt("%s ->> %s",key,value) --debug
   end
   return copy
end

function tableappend(toinsert,intothis)
   for key,value in pairs(toinsert) do
      table.insert(intothis,value)
   end
end

function tablekeyappend(toinsert,intothis)
   for key,value in pairs(toinsert) do
      table.insert(intothis,key,value)
   end
end
