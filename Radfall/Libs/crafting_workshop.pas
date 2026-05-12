unit crafting_workshop;

var
    flst_radio, kywd_radio: IInterface;
    

procedure processWorkshopCobj(cobj, cnam: IInterface);
var
    components, cmpo: IInterface;
    fileName : string;

begin
    //skip custom patched radfall stuff
    fileName := getFileName(getFile(winningOverride(cobj)));
    if (copy(filename, 1,7) = 'Radfall') then exit;
    if (copy(filename, 1,3) = 'SBS') then exit;
    
    addMessage('Processing: ' + FullPath(cobj));
    cobj := copyOverrideToPatch(cobj);

    if containsText(getElementEditValues(cnam, 'FULL'), 'radio') then begin
        if not assigned(flst_radio) then begin
            flst_radio := copyOverrideToPatch(getRecord('Radfall.esp', 'FLST', 'workshopScrapRecipe_Radio'));
            kywd_radio := getRecord('Radfall.esp', 'KYWD', 'WorkshopRecipeFilterMechanical02Tech');
        end;
        addToFormlist(cnam, flst_radio);
        cleanRecipe(cobj);
        addRecipeComponent(cobj, c_radio, 1);
        setEditValue(elementByIndex(elementByPath(cobj, 'FNAM'), 0), getId(kywd_radio));
    end
    else if containsText(getElementEditValues(cnam, 'FULL'), 'turret') then begin
        addRecipeComponent(cobj, c_motor, 1);
    end
    else disableRecipe(cobj, globalEnableVanillaWorkshop);

end;


//###
end.