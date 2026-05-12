unit Radfall_Main;

uses 'Radfall\Libs\log';
uses 'Radfall\Libs\wtf_xpf';
uses 'Radfall\Libs\util';
uses 'Radfall\Libs\barter';
uses 'Radfall\Libs\armor';
uses 'Radfall\Libs\furniture';
uses 'Radfall\Libs\weapon';
uses 'Radfall\Libs\crafting';
uses 'Radfall\Libs\perks';
uses 'Radfall\Libs\misc';
uses 'Radfall\Libs\util_distribute_omods';


const
    file_radfall = fileByName('Radfall.esp');
var
    config: TIniFile;

//============================================================================  
function Initialize: integer;
var
    i: Integer;
    str: string;

begin
    if not assigned(file_radfall) then raise exception.create('Missing Radfall.esp');
    if assigned(fileByName('M8r Complex Sorter.esp')) then raise exception.create('Detected Sorting - reload without the sorter to run the patcher');
    PatchFileByAuthor('RadfallPatcher');
    AddMasterIfMissing(patchFile, 'Radfall.esp');
    config := TIniFile.Create('Edit Scripts\Radfall\Config.ini');
    addmessage('Config Loaded');

    initWeapArmoConfig();// required by weapon and armor modules
    initArmor();
    initWeapon();
    initMisc();

    runArmor();
    runBarter();
    runFurniture();
    
    runWeapon();
    runCrafting(); //REQUIRES runWeapon() and runArmor() to have run first to populate cache

    swapAdVictoriam(); //this needs to run LAST, so that the copy to patch doesn't prevent records from being queued
    if assigned(fileByName('LunarFalloutOverhaul.esp')) then swapLunarBlacksmith();
end;

//============================================================================  
function Finalize: integer;
var
    i: Integer;
    fileName : string;
begin
    addMessage('Finalizing Patch File');
    for i := recordCount(patchFile) -1 downto 0 do removeIdenticalToMaster(recordByIndex(patchFile, i));        
    cleanMasters(patchFile);
    
    //add radfall patches as masters to make ordering easier
    for i := 0 to Pred(FileCount) do begin
        fileName := GetFileName(FileByIndex(i));
        if not containsText(fileName, 'Radfall') then continue;
        if fileName = getFileName(patchFile) then continue;
        AddMasterIfMissing(patchfile, GetFileName(FileByIndex(i)));
    end;

    sortMasters(patchFile);
    
end;

//###
end.