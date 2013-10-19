-- A collection of useful game tools

if stringtools==nil then
stringtools=require "stringdb" end
if tabletools==nil then
tabletools=require "tableutils" end

function addtogamesys(defaults)
   if GAMESYS==nil then
   GAMESYS={} end

   if defaults~=nil then
      for setting,default in pairs(defaults) do
         if GAMESYS[setting]==nil then
            GAMESYS[setting]=DEFAULT[setting]
            print("Using default for",setting) --debug
         end
      end
   end
end

addtogamesys(DEFAULT)

function rollD(max)
   return srandom(seedobj,1,max)
end

-- rough adaptation of Knuth float generator
function srandom( seedobj, fVal1, fVal2 )
    local mod = math.fmod
    local floor = math.floor
    local abs = math.abs

    local B =  4000000
    
    local ma = seedobj.ma
    local seed = seedobj.seed
    local mj, mk
    if seed < 0 or not ma then
        ma = {}
        seedobj.ma = ma
        mj = abs( 1618033 - abs( seed ) )
        mj = mod( mj, B )
        ma[55] = mj
        mk = 1
        for i = 1, 54 do
            local ii = mod( 21 * i,  55 )
            ma[ii] = mk
            mk = mj - mk
            if mk < 0 then mk = mk + B end
            mj = ma[ii]
        end
        for k = 1, 4 do
            for i = 1, 55 do
                ma[i] = ma[i] - ma[ 1 + mod( i + 30,  55) ]
                if ma[i] < 0 then ma[i] = ma[i] + B end
            end
        end
        seedobj.inext = 0
        seedobj.inextp = 31
        seedobj.seed = 1
    end -- if
    local inext = seedobj.inext
    local inextp = seedobj.inextp
    inext = inext + 1
    if inext == 56 then inext = 1 end
    seedobj.inext = inext
    inextp = inextp + 1
    if inextp == 56 then inextp = 1 end
    seedobj.inextp = inextp
    mj = ma[ inext ] - ma[ inextp ]
    if mj < 0 then mj = mj + B end
    ma[ inext ] = mj
    local temp_rand = mj / B
    if fVal2 then
        return floor( fVal1 + 0.5 + temp_rand * ( fVal2 - fVal1 ) )
    elseif fVal1 then
        return floor( temp_rand * fVal1 ) + 1
    else
        return temp_rand
    end
end

    -- Note: seedobj must be a table with a field named `seed`;
    -- this field must be negative; after the first number has
    -- been generated, the seedobj table will be populated with
    -- additional state needed to generate numbers; changing its
    -- `seed` field to a negative number will reinitialize the
    -- generator and start a new pseudorandom sequence.
seeder = -1 * os.time()
seedobj = { seed = seeder }

function displaythis(text)
   io.write(text)
end

function prt(textstring,var1,var2,var3,var4)
   --I'm just sick of how long string.format is
   local txt=string.format(textstring,var1,var2,var3,var4).."\n"
   displaythis(txt)
end

function getcommand(prompt,commandset)
   --formats and displays a prompt
   --only returns valid responses
   local i,com
   local validcom={}
   prompt=prompt.." ( "
   for i,com in pairs(commandset) do
      prompt=prompt..com
      if (i~=#commandset) then
      prompt=prompt.." / " end
      validcom[com]=true
   end
   prompt=prompt.." ) ?"
   io.write(prompt)
   repeat
      io.flush()
      answer=io.read()
      -- print("io read:",answer) --debug
   until (validcom[answer]==true)
   return answer
end

function tablesum(key, tableslist)
   --given a key and a table of tables, sums the values of each item in the tablelist and returns this as a number
   local total=0
   for count,onetable in pairs(tableslist) do
      --prt("Getting %s from list item %s",key,count) --debug
      if (onetable[key]==nil) then onetable[key]=0 end
      total=total+onetable[key]

      --prt("adding %s for %s",onetable[key],key) --debug

   end
   return total
end

function tablesumtable(keytable, targettable, tableslist)
   --given a table with keys and another table of tables, attempts to sum the values of each key in the target tables abd returns this as a table
   local sumtable={}
   local targtable={}
   for count,onetable in pairs(tableslist) do
      --prt("Getting %s from list item %s",targettable,count) --debug
      targtable=onetable[targettable]
      for key,value in pairs(keytable) do
         if (sumtable[key]==nil) then sumtable[key]=0 end

         if targtable[key]==nil then
         targtable[key]=0 end
         --prt("adding %s for %s",targtable[key],key) --debug
         sumtable[key]=sumtable[key]+targtable[key]
      end
   end
   return sumtable
end