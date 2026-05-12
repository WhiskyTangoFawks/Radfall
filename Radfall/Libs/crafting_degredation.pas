unit crafting_degradation;
var
    template_mgef, template_ench : IInterface;

procedure initDegredation();
begin
    template_mgef := getRecord('Radfall.esp', 'MGEF', 'template_DegradeOmod');
    template_ench := getRecord('Radfall.esp', 'ENCH', 'ench_Template_DowngradeReceiver');
end;

//============================================================================ 
procedure addDegredationSpell(omod, weap: IInterface);
var
    mgef, ench, properties, downgradeOmodProperty, downgradeOmod, newProperty : IInterface;
    i : integer;
  
begin
    downgradeOmod := getDowngradedOmod(omod);
  
    if not assigned(downgradeOmod) then begin
      info('Unable to find OMOD referencing mnam keyword for downagrade');
      exit;
    end;
    info('Adding downgrade');
    omod := copyOverrideToPatch(omod);
    //get the template, copy and rename
    mgef := copyRecordToFile(template_mgef, patchFile, true);
    SetElementEditValues(mgef, 'EDID', editorId(omod) + '_downgradeMGEF');
      
    //assign script mgef properties
    properties := ElementByPath(ElementByindex(ElementByPath(mgef, 'VMAD\Scripts'), 0), 'Properties');
    downgradeOmodProperty := ElementByIndex(Properties, 1);

    AddRequiredElementMasters(downgradeOmod, patchFile, false);
    SetElementEditValues(downgradeOmodProperty, 'Value\Object Union\Object V2\FormID', IntToHex(GetLoadOrderFormID(downgradeOmod) , 8));

    //copy ench
    ench := copyRecordToFile(template_ench, patchFile, true);
    SetElementEditValues(ench, 'EDID', 'ench_downgradeReceiver_' + getElementEditValues(omod, 'EDID'));

    //assign mgef to ench
    SetElementEditValues(ElementByIndex(ElementByPath(ench, 'Effects'), 0), 'EFID', IntToHex(GetLoadOrderFormID(mgef) , 8));

    //assign ench to omod
    properties := ElementByPath(omod, 'DATA\Properties');
    if not Assigned(properties) then logg(5, 'Unable so assign properties during ench assignment to omod');
    newProperty := ElementAssign(properties, HighInteger, nil, False);
    if not Assigned(newProperty) then error('**ERROR** Failed to add new property during ench assignment to omod');
    SetElementEditValues(newProperty, 'Value Type', 'FormID,Int');
    SetElementEditValues(newProperty, 'Function Type', 'ADD');
    SetElementEditValues(newProperty, 'Property', 'Enchantments');
    SetElementEditValues(newProperty, 'Value 1 - FormID', IntToHex(GetLoadOrderFormID(ench) , 8));

end;


//============================================================================  
function getDowngradedOmod(omod: IInterface): IInterface;
var
  omodRef, mnam, mnamRef, ap: IInterface;
  i, targetDamage: integer;
  isAuto: Boolean;
  value, targetString: string;
begin
  
  mnam := LinksTo(ElementByIndex(ElementBySignature(omod, 'MNAM'), 0));
  ap := LinksTo(ElementByPath(omod, 'DATA\Attach Point'));
  //constructs a fingerprint string, that can be downgraded
  value := getReceiverValue(omod);
  targetString := downgradeReceiverString(value);
  if targetString = '' then begin
    trace('skipping base level omod');
    exit;
  end;
  

  for i := 0 to ReferencedByCount(mnam)-1 do begin
    omodRef := ReferencedByIndex(mnam, i);
    if (Signature(omodRef) <> 'OMOD') then continue;
    if not isWinningOverride(omodRef) then continue;
    if ap <> LinksTo(ElementByPath(omodRef, 'DATA\Attach Point')) then continue;
    if (getElementEditValues(omod, 'Record Header\record flags\Mod Collection') = '1') then continue;
    if ReferencedByCount(omodRef) = 0 then continue;
    if containsText(EditorId(omodRef), 'template') or containsText(EditorId(omodRef), 'not used') then continue;
    if targetString <> getReceiverValue(omodRef) then continue;

    result := omodRef;
    debug('get Damage Level OMOD found by MNAM reference ' + EditorID(result));
    exit;
    
  end;

  warn('Unable to find damage level omod');

end;

//============================================================================  
function getReceiverValue(omod: IInterface): string;
var
  i, damage, burst, crit, arPen: integer;
  properties: IInterface;
  prop, fire, keyword, enchantment: string;
  isAuto: boolean;
begin
  damage := 0;
  burst := 0;
  crit := 0;
  arPen := 0;
  isAuto := false;
  
  properties := ElementByPath(omod, 'DATA\Properties');
  for i := 0 to ElementCount(properties)-1 do begin
    prop := getElementEditValues(ElementByIndex(properties, i), 'Property');
      if prop = 'Keywords' then begin
      
      keyword := editorId(linksTo(elementByPath(ElementByIndex(properties, i), 'Value 1')));
      if keyword = 'WeaponTypeAutomatic' then isAuto := true
      else if copy(keyword, 1, 25) = 'dn_HasReceiver_MoreDamage' then damage := strToInt(copy(keyword, 26, 26))
      else if copy(keyword, 1, 20) = 'dn_HasReceiver_Crank' then damage := (strToInt(copy(keyword, 21, 21))-1)
      else if copy(keyword, 1, 30) = 'dn_HasReceiver_BetterCriticals' then crit := strToInt(copy(keyword, 31, 31))
      else if copy(keyword, 1, 28) = 'dn_HasReceiver_ArmorPiercing' then arPen := strToInt(copy(keyword, 29, 29));
    end
    else if prop = 'Enchantments' then begin
      enchantment := editorId(linksTo(elementByPath(ElementByIndex(properties, i), 'Value 1')));
      if copy(enchantment, 1, 29) = 'T6M_Ench_BurstFire_Interrupt_' then burst := strToInt(copy(enchantment, 30, 30));
    end;
  end;

  result := intToStr(damage);
  if (burst > 0) then result := result + 'burst' + intToStr(burst)
  else if isAuto then result := result + 'auto';
  
  if (crit > 0) then result := result + 'crit' + intToStr(crit)
  else if (arPen > 0) then result := result + 'arPen' + intToStr(arPen);
end;
//============================================================================ 
function downgradeReceiverString(s : string): string;
var
  targetDamage: integer;
begin
  result := '';
  if containsText(s, 'arPen2') then result := stringReplace(s, 'arPen2', 'arPen1', [rfReplaceAll])
  else if containsText(s, 'arPen1') then result := stringReplace(s, 'arPen1', '', [rfReplaceAll])
  else if containsText(s, 'crit2') then result := stringReplace(s, 'arPen1', 'crit1', [rfReplaceAll])
  else if containsText(s, 'crit1') then result := stringReplace(s, 'crit1', '', [rfReplaceAll])
  else begin
    targetDamage := StrToInt(copy(s, 1, 1))-1;
    if (targetDamage < 0) then exit;
    result := intToStr(targetDamage) + copy(s, 2, length(s));
  end;
end;


end.