unit util_distribute_omods;

var
    randomized_apprs: TStringList;

procedure initWeapArmoConfig();
begin
    randomized_apprs := newSortedTStringList();
    randomized_apprs.delimitedText := config.readString('Distribution', 'randomized_apprs', '');
    info('loaded randomized_apprs=' + randomized_apprs.delimitedText);
end;

//============================================================================  
function shouldReplaceOmodWithModcol(omod: IInterface): boolean;
var
    appr : IInterface;
begin
    result := false;
    if (getElementEditValues(omod, 'Record Header\record flags\Mod Collection') = '1') then exit;
    appr := LinksTo(ElementByPath(omod, 'DATA\Attach Point'));
    result := (randomized_apprs.indexOf(editorId(appr)) > -1);
end;

//============================================================================  
function replaceStandardOmodsWithModcols(item: IInterface; keywordList: TStringList): boolean;
var
   list, entry, listmods, omod, modcol: IInterface;
   i, J: integer;

begin
    debug('checking for replaceable modcols');
    list := ElementByPath(item, 'Object Template\Combinations');
    //Processing a weapon or armor record			
    //iterate through the templates
    for i := 0 to ElementCount(list)-1 do Begin
        entry := ElementByIndex(list, i);
        listmods := ElementByPath(entry, 'OBTS\Includes');
        for j := 0 to ElementCount(listmods)-1 do Begin
            omod := LinksTo(elementByPath(ElementByIndex(listmods, j), 'Mod'));
            if not shouldReplaceOmodWithModcol(omod) then continue;
            
            modcol := getLargestModcol(omod, item, keywordList);
            trace('replacing ' + editorId(omod) + ' -> ' + editorId(modcol));
            if assigned(modcol) then setElementEditValues(ElementByIndex(listmods, j), 'Mod', IntToHex(GetLoadOrderFormID(modcol), 8))
            end;
        end;
   end;

//============================================================================  
function getLargestModcol(e, weap: IInterface; keywordList: TStringList): IInterface;
var
  ref, mnam, firstEntry: IInterface;
  i: integer;
begin
    for i := 0 to ReferencedByCount(e)-1 do begin
        ref := ReferencedByIndex(e, i);
        if not isWinningOverride(ref) then continue;
        if Signature(ref) <> 'OMOD' then continue;
        if not getElementEditValues(ref, 'Record Header\record flags\Mod Collection') = 1 then continue;
        if (ElementCount(ElementByPath(ref, 'DATA\Includes')) < 2) then continue; //skip if modcol only has a single entry
        firstEntry := LinksTo(ElementByPath(ref, 'DATA\Includes\Include #1\Mod'));
        mnam := LinksTo(ElementByIndex(ElementBySignature(firstEntry, 'MNAM'), 0));
        if not assigned(mnam) then continue;
        if (keywordList.indexOf(editorId(mnam)) = -1) then continue;
        
        if not assigned(result) then result := ref
        else if ElementCount(ElementByPath(ref, 'DATA\Includes')) > ElementCount(ElementByPath(result, 'DATA\Includes')) then result := ref;

    end;
end;

end.