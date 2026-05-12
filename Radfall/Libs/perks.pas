unit radfall_perks;

procedure swapAdVictoriam();
var
    science, robotics, refBy: IINterface;
    i : integer;
begin

    
    info('Replacing references ' + editorId(science) + ' -> ' + editorId(robotics));
    for i := 0 to ReferencedByCount(science)-1 do begin
        refBy := ReferencedByIndex(science, i);
        if not isWinningOverride(refBy) then continue;
        if signature(refBy) = 'PERK' then continue;
        if signature(refBy) = 'FLST' then continue;
        
        refBy := copyOverrideToPatch(refBy);
        compareExchangeFormId(refBy, GetLoadOrderFormID(science), GetLoadOrderFormID(robotics));
    end;

    science := getRecord('Fallout4.esm', 'PERK', 'Science02');
    robotics := getRecord('Fallout4.esm', 'PERK', 'RoboticsExpert02');
    info('Replacing references ' + editorId(robotics) + ' -> ' + editorId(science));
    for i := 0 to ReferencedByCount(robotics)-1 do begin
        refBy := ReferencedByIndex(robotics, i);
        if not isWinningOverride(refBy) then continue;
        if signature(refBy) = 'PERK' then continue;
        if signature(refBy) = 'FLST' then continue;
        
        refBy := copyOverrideToPatch(refBy);
        compareExchangeFormId(refBy, GetLoadOrderFormID(robotics), GetLoadOrderFormID(science));
    end;

        science := getRecord('Fallout4.esm', 'PERK', 'Science03');
    robotics := getRecord('Fallout4.esm', 'PERK', 'RoboticsExpert03');
    info('Replacing references ' + editorId(robotics) + ' -> ' + editorId(science));
    for i := 0 to ReferencedByCount(robotics)-1 do begin
        refBy := ReferencedByIndex(robotics, i);
        if not isWinningOverride(refBy) then continue;
        if signature(refBy) = 'PERK' then continue;
        if signature(refBy) = 'FLST' then continue;
        
        refBy := copyOverrideToPatch(refBy);
        compareExchangeFormId(refBy, GetLoadOrderFormID(robotics), GetLoadOrderFormID(science));
    end;
end;



procedure swapLunarBlacksmith();
var
    lunarBlacksmith, radfallBlacksmith, refBy: IINterface;
    i : integer;
begin
    lunarBlacksmith := getRecord('LunarFalloutOverhaul.esp', 'PERK', 'Blacksmith04');
    radfallBlacksmith := getRecord('Radfall.esp', 'PERK', 'Blacksmith04');
    
    info('Replacing references ' + editorId(lunarBlacksmith) + ' -> ' + editorId(radfallBlacksmith));
    for i := 0 to ReferencedByCount(lunarBlacksmith)-1 do begin
        refBy := ReferencedByIndex(lunarBlacksmith, i);
        if not isWinningOverride(refBy) then continue;
        if signature(refBy) = 'PERK' then continue;
        if signature(refBy) = 'FLST' then continue;
        
        refBy := copyOverrideToPatch(refBy);
        compareExchangeFormId(refBy, GetLoadOrderFormID(lunarBlacksmith), GetLoadOrderFormID(radfallBlacksmith));
    end;
end;

//============================================================================  
//oldPerk: EDID, newPerk: formId
function swapPerkReqs(cobj: IInterface; oldPerk, newPerk:String): String;
var
  conds: IInterface;
  i: integer;
  edid: string;
begin
  conds := ElementByName(cobj, 'Conditions');
  if assigned(conds) then for i := 0 to Pred(ElementCount(conds)) do begin 
    edid := EditorId(linksTo(ElementByPath(ElementByIndex(conds, i), 'CTDA\Perk')));
    if (edid = oldPerk) then setElementEditValues(ElementByIndex(conds, i), 'CTDA\Perk', newPerk)
  end;
end;

end.